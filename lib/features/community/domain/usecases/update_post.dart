import '../repositories/community_repository.dart';

/// Business operation: edit the body text of an existing post.
///
/// Rules enforced:
/// - user must be signed in
/// - post ID must be present
/// - new body must have content and be within the same length limits
///   as creation
/// - the repository re-applies danger-keyword moderation to the edited
///   body, so an edit cannot slip a flagged term past moderation
class UpdatePost {
  final CommunityRepository repository;

  UpdatePost(this.repository);

  /// Executes the post-update flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [CommunityException] if persistence fails.
  Future<void> call({
    required String postId,
    required String authorUserId,
    required String body,
  }) async {
    if (authorUserId.trim().isEmpty) {
      throw ArgumentError('You must be signed in to edit a post.');
    }

    if (postId.trim().isEmpty) {
      throw ArgumentError('Post ID is required.');
    }

    final trimmedBody = body.trim();

    if (trimmedBody.isEmpty) {
      throw ArgumentError('Post cannot be empty.');
    }

    if (trimmedBody.length < 3) {
      throw ArgumentError('Post must be at least 3 characters.');
    }

    if (trimmedBody.length > 2000) {
      throw ArgumentError('Post cannot exceed 2000 characters.');
    }

    return repository.updatePost(
      postId: postId,
      body: trimmedBody,
    );
  }
}