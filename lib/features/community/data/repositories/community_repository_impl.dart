import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/community_group.dart';
import '../../domain/entities/group_membership.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/reply.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_firestore_datasource.dart';

/// Concrete implementation of [CommunityRepository] backed by Firestore.
///
/// Delegates to the community datasource and translates
/// Firebase-specific exceptions into domain [CommunityException]s.
class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityFirestoreDatasource _datasource;

  CommunityRepositoryImpl(this._datasource);

  // ---------- GROUPS ----------

  @override
  Future<List<CommunityGroup>> getAvailableGroups({
    required int pregnancyWeek,
    String? locationHint,
  }) async {
    try {
      return await _datasource.getAvailableGroups(
        pregnancyWeek: pregnancyWeek,
        locationHint: locationHint,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<CommunityGroup?> getGroup(String groupId) async {
    try {
      return await _datasource.getGroup(groupId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Stream<CommunityGroup> watchGroup(String groupId) {
    return _datasource.watchGroup(groupId);
  }

  // ---------- MEMBERSHIPS ----------

  @override
  Future<GroupMembership> joinGroup({
    required String userId,
    required String groupId,
    bool postsAnonymously = true,
  }) async {
    try {
      return await _datasource.joinGroup(
        userId: userId,
        groupId: groupId,
        postsAnonymously: postsAnonymously,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> leaveGroup(String membershipId) async {
    try {
      await _datasource.leaveGroup(membershipId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<GroupMembership>> getUserMemberships(String userId) async {
    try {
      return await _datasource.getUserMemberships(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> updateAnonymityPreference({
    required String membershipId,
    required bool postsAnonymously,
  }) async {
    try {
      await _datasource.updateAnonymityPreference(
        membershipId: membershipId,
        postsAnonymously: postsAnonymously,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- POSTS ----------

  @override
  Future<Post> createPost({
    required String groupId,
    required String authorUserId,
    required String body,
    String? photoUrl,
    bool isAnonymous = true,
    int? pregnancyWeekAtPost,
  }) async {
    try {
      return await _datasource.createPost(
        groupId: groupId,
        authorUserId: authorUserId,
        body: body,
        photoUrl: photoUrl,
        isAnonymous: isAnonymous,
        pregnancyWeekAtPost: pregnancyWeekAtPost,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<Post>> getGroupPosts({
    required String groupId,
    int limit = 20,
    DateTime? before,
  }) async {
    try {
      return await _datasource.getGroupPosts(
        groupId: groupId,
        limit: limit,
        before: before,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Stream<List<Post>> watchGroupPosts(String groupId) {
    return _datasource.watchGroupPosts(groupId);
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _datasource.deletePost(postId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> toggleLikePost({
    required String postId,
    required bool liked,
  }) async {
    try {
      await _datasource.toggleLikePost(postId: postId, liked: liked);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- REPLIES ----------

  @override
  Future<Reply> createReply({
    required String postId,
    required String authorUserId,
    required String body,
    bool isAnonymous = true,
  }) async {
    try {
      return await _datasource.createReply(
        postId: postId,
        authorUserId: authorUserId,
        body: body,
        isAnonymous: isAnonymous,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<Reply>> getPostReplies(String postId) async {
    try {
      return await _datasource.getPostReplies(postId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Stream<List<Reply>> watchPostReplies(String postId) {
    return _datasource.watchPostReplies(postId);
  }

  @override
  Future<void> deleteReply(String replyId) async {
    try {
      await _datasource.deleteReply(replyId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- ERROR TRANSLATION ----------

  CommunityException _translateException(FirebaseException e) {
    final code = e.code;
    switch (code) {
      case 'permission-denied':
        return const CommunityException(
          'You do not have permission for this action. '
              'Please sign in again.',
          code: 'permission-denied',
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return const CommunityException(
          'Could not reach the community. '
              'Please check your connection and try again.',
          code: 'service-unavailable',
        );
      case 'not-found':
        return const CommunityException(
          'This content could not be found.',
          code: 'not-found',
        );
      case 'network-request-failed':
        return const CommunityException(
          'No internet connection. '
              'Please try again when you are online.',
          code: 'network-error',
        );
      default:
        return CommunityException(
          e.message ?? 'Something went wrong. Please try again.',
          code: code,
        );
    }
  }
}