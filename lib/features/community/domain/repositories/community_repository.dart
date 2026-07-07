import '../entities/community_group.dart';
import '../entities/group_membership.dart';
import '../entities/post.dart';
import '../entities/reply.dart';

/// Contract for community operations — groups, memberships, posts, replies.
///
/// The data layer implements this using Firestore.
abstract class CommunityRepository {
  // ---------- GROUPS ----------

  /// Fetch all groups the user is eligible to see (based on filters).
  Future<List<CommunityGroup>> getAvailableGroups({
    required int pregnancyWeek,
    String? locationHint,
  });

  /// Fetch a single group by ID.
  Future<CommunityGroup?> getGroup(String groupId);

  /// Real-time stream of a group's details (member count, etc.).
  Stream<CommunityGroup> watchGroup(String groupId);

  // ---------- MEMBERSHIPS ----------

  /// Join a group. Creates a GroupMembership record.
  ///
  /// If [postsAnonymously] is true (default), all posts and replies
  /// by this user in this group hide their identity.
  Future<GroupMembership> joinGroup({
    required String userId,
    required String groupId,
    bool postsAnonymously = true,
  });

  /// Leave a group. Deletes the GroupMembership record.
  Future<void> leaveGroup(String membershipId);

  /// Fetch all groups the given user has joined.
  Future<List<GroupMembership>> getUserMemberships(String userId);

  /// Update a membership's anonymity preference.
  Future<void> updateAnonymityPreference({
    required String membershipId,
    required bool postsAnonymously,
  });

  // ---------- POSTS ----------

  /// Create a new post in a group.
  ///
  /// Posts mentioning emergency or danger keywords go into pending
  /// moderation status until reviewed.
  Future<Post> createPost({
    required String groupId,
    required String authorUserId,
    required String body,
    String? photoUrl,
    bool isAnonymous = true,
    int? pregnancyWeekAtPost,
  });

  /// Fetch posts in a group, most recent first.
  Future<List<Post>> getGroupPosts({
    required String groupId,
    int limit = 20,
    DateTime? before,
  });

  /// Real-time stream of a group's posts.
  Stream<List<Post>> watchGroupPosts(String groupId);

  /// Delete a post. Only the author can delete their own posts.
  Future<void> deletePost(String postId);

  /// Increment or decrement the likes count on a post.
  Future<void> toggleLikePost({
    required String postId,
    required bool liked,
  });

  // ---------- REPLIES ----------

  /// Create a reply to a post.
  Future<Reply> createReply({
    required String postId,
    required String authorUserId,
    required String body,
    bool isAnonymous = true,
  });

  /// Fetch replies to a post, oldest first.
  Future<List<Reply>> getPostReplies(String postId);

  /// Real-time stream of replies to a post.
  Stream<List<Reply>> watchPostReplies(String postId);

  /// Delete a reply. Only the author can delete their own replies.
  Future<void> deleteReply(String replyId);
}

/// Base exception for community operations.
class CommunityException implements Exception {
  final String message;
  final String? code;

  const CommunityException(this.message, {this.code});

  @override
  String toString() => 'CommunityException($code): $message';
}