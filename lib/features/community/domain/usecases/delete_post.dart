import '../repositories/community_repository.dart';

/// Business operation: delete a post.
///
/// Rules enforced:
/// - user must be signed in
/// - post ID must be present
///
/// Ownership (only the author may delete) is enforced by Firestore
/// security rules; this use case guards the basic preconditions.
class DeletePost {
  final CommunityRepository repository;

  DeletePost(this.repository);

  /// Executes the delete flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [CommunityException] if persistence fails.
  Future<void> call({
    required String postId,
    required String authorUserId,
  }) async {
    if (authorUserId.trim().isEmpty) {
      throw ArgumentError('You must be signed in to delete a post.');
    }

    if (postId.trim().isEmpty) {
      throw ArgumentError('Post ID is required.');
    }

    return repository.deletePost(postId);
  }
}