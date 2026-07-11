import '../entities/reply.dart';
import '../repositories/community_repository.dart';

/// Business operation: create a reply to a community post.
///
/// Rules enforced:
/// - user must be signed in
/// - post ID must be provided
/// - body must have content and be within tighter length limits than posts
///   (replies are meant to be short)
class CreateReply {
  final CommunityRepository repository;

  CreateReply(this.repository);

  /// Executes the reply-creation flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [CommunityException] if persistence fails.
  Future<Reply> call({
    required String postId,
    required String authorUserId,
    required String body,
    bool isAnonymous = true,
  }) async {
    // ---------- VALIDATION ----------

    if (authorUserId.trim().isEmpty) {
      throw ArgumentError('You must be signed in to reply.');
    }

    if (postId.trim().isEmpty) {
      throw ArgumentError('Post ID is required.');
    }

    final trimmedBody = body.trim();

    if (trimmedBody.isEmpty) {
      throw ArgumentError('Reply cannot be empty.');
    }

    if (trimmedBody.length < 2) {
      throw ArgumentError('Reply must be at least 2 characters.');
    }

    if (trimmedBody.length > 500) {
      throw ArgumentError('Reply cannot exceed 500 characters.');
    }

    // ---------- CREATE ----------

    return repository.createReply(
      postId: postId,
      authorUserId: authorUserId,
      body: trimmedBody,
      isAnonymous: isAnonymous,
    );
  }
}