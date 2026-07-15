import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/community_group_model.dart';
import '../models/group_membership_model.dart';
import '../models/post_model.dart';
import '../models/reply_model.dart';

/// Low-level data source that wraps four Firestore collections:
/// community_groups, group_memberships, posts, replies.
///
/// Handles all reads, writes, and real-time streams for the community
/// feature. This is the only community class that imports Firebase.
class CommunityFirestoreDatasource {
  final FirebaseFirestore _firestore;

  CommunityFirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _groupsCollection =>
      _firestore.collection('community_groups');

  CollectionReference<Map<String, dynamic>> get _membershipsCollection =>
      _firestore.collection('group_memberships');

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _firestore.collection('posts');

  CollectionReference<Map<String, dynamic>> get _repliesCollection =>
      _firestore.collection('replies');

  // ---------- GROUPS ----------

  /// Fetch all groups. Filtering by pregnancy week / location happens
  /// in the use case (GetAvailableGroups) rather than in Firestore
  /// itself — this keeps the Firestore query simple and avoids needing
  /// composite indexes for every combination.
  Future<List<CommunityGroupModel>> getAvailableGroups({
    required int pregnancyWeek,
    String? locationHint,
  }) async {
    final snapshot = await _groupsCollection.get();
    return snapshot.docs
        .map((doc) => CommunityGroupModel.fromFirestore(doc))
        .toList();
  }

  Future<CommunityGroupModel?> getGroup(String groupId) async {
    final doc = await _groupsCollection.doc(groupId).get();
    if (!doc.exists) return null;
    return CommunityGroupModel.fromFirestore(doc);
  }

  Stream<CommunityGroupModel> watchGroup(String groupId) {
    return _groupsCollection.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Group $groupId no longer exists.');
      }
      return CommunityGroupModel.fromFirestore(doc);
    });
  }

  // ---------- MEMBERSHIPS ----------

  Future<GroupMembershipModel> joinGroup({
    required String userId,
    required String groupId,
    bool postsAnonymously = true,
  }) async {
    final now = DateTime.now();
    final data = {
      'user_id': userId,
      'group_id': groupId,
      'posts_anonymously': postsAnonymously,
      'joined_at': Timestamp.fromDate(now),
      'role': 'member',
    };

    final docRef = await _membershipsCollection.add(data);

    // Increment the group's member count
    await _groupsCollection.doc(groupId).update({
      'member_count': FieldValue.increment(1),
    });

    return GroupMembershipModel(
      membershipId: docRef.id,
      userId: userId,
      groupId: groupId,
      postsAnonymously: postsAnonymously,
      joinedAt: now,
    );
  }

  Future<void> leaveGroup(String membershipId) async {
    final doc = await _membershipsCollection.doc(membershipId).get();
    if (!doc.exists) return;

    final groupId = doc.data()?['group_id'] as String?;
    await _membershipsCollection.doc(membershipId).delete();

    if (groupId != null) {
      await _groupsCollection.doc(groupId).update({
        'member_count': FieldValue.increment(-1),
      });
    }
  }

  Future<List<GroupMembershipModel>> getUserMemberships(
      String userId,
      ) async {
    final snapshot = await _membershipsCollection
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => GroupMembershipModel.fromFirestore(doc))
        .toList();
  }

  Future<void> updateAnonymityPreference({
    required String membershipId,
    required bool postsAnonymously,
  }) async {
    await _membershipsCollection
        .doc(membershipId)
        .update({'posts_anonymously': postsAnonymously});
  }

  // ---------- POSTS ----------

  Future<PostModel> createPost({
    required String groupId,
    required String authorUserId,
    required String body,
    String? photoUrl,
    bool isAnonymous = true,
    int? pregnancyWeekAtPost,
  }) async {
    // Auto-flag posts containing danger keywords for moderation
    final dangerKeywords = [
      'bleeding',
      'contractions',
      'severe pain',
      'emergency',
      'help me',
      'no movement',
    ];
    final lowerBody = body.toLowerCase();
    final needsModeration =
    dangerKeywords.any((kw) => lowerBody.contains(kw));

    final now = DateTime.now();
    final data = {
      'group_id': groupId,
      'author_user_id': authorUserId,
      'body': body,
      'photo_url': photoUrl,
      'is_anonymous': isAnonymous,
      'moderation_status': needsModeration ? 'pending' : 'approved',
      'likes_count': 0,
      'replies_count': 0,
      'pregnancy_week_at_post': pregnancyWeekAtPost,
      'created_at': Timestamp.fromDate(now),
    };

    final docRef = await _postsCollection.add(data);
    final saved = await docRef.get();
    return PostModel.fromFirestore(saved);
  }

  Future<List<PostModel>> getGroupPosts({
    required String groupId,
    int limit = 20,
    DateTime? before,
  }) async {
    Query<Map<String, dynamic>> query = _postsCollection
        .where('group_id', isEqualTo: groupId)
        .orderBy('created_at', descending: true)
        .limit(limit);

    if (before != null) {
      query = query.where(
        'created_at',
        isLessThan: Timestamp.fromDate(before),
      );
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostModel.fromFirestore(doc))
        .toList();
  }

  Stream<List<PostModel>> watchGroupPosts(String groupId) {
    return _postsCollection
        .where('group_id', isEqualTo: groupId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostModel.fromFirestore(doc))
        .toList());
  }

  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }

  Future<void> toggleLikePost({
    required String postId,
    required bool liked,
  }) async {
    await _postsCollection.doc(postId).update({
      'likes_count': FieldValue.increment(liked ? 1 : -1),
    });
  }

  // ---------- REPLIES ----------

  Future<ReplyModel> createReply({
    required String postId,
    required String authorUserId,
    required String body,
    bool isAnonymous = true,
  }) async {
    final now = DateTime.now();
    final data = {
      'post_id': postId,
      'author_user_id': authorUserId,
      'body': body,
      'is_anonymous': isAnonymous,
      'moderation_status': 'approved',
      'likes_count': 0,
      'created_at': Timestamp.fromDate(now),
    };

    final docRef = await _repliesCollection.add(data);

    // Increment the parent post's reply count
    await _postsCollection.doc(postId).update({
      'replies_count': FieldValue.increment(1),
    });

    final saved = await docRef.get();
    return ReplyModel.fromFirestore(saved);
  }

  Future<List<ReplyModel>> getPostReplies(String postId) async {
    final snapshot = await _repliesCollection
        .where('post_id', isEqualTo: postId)
        .orderBy('created_at', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => ReplyModel.fromFirestore(doc))
        .toList();
  }

  Stream<List<ReplyModel>> watchPostReplies(String postId) {
    return _repliesCollection
        .where('post_id', isEqualTo: postId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReplyModel.fromFirestore(doc))
        .toList());
  }

  Future<void> deleteReply(String replyId) async {
    final doc = await _repliesCollection.doc(replyId).get();
    if (!doc.exists) return;

    final postId = doc.data()?['post_id'] as String?;
    await _repliesCollection.doc(replyId).delete();

    if (postId != null) {
      await _postsCollection.doc(postId).update({
        'replies_count': FieldValue.increment(-1),
      });
    }
  }
}