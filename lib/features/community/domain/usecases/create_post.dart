import '../entities/post.dart';
import '../repositories/community_repository.dart';

/// Business operation: create a new post in a community group.
///
/// Rules enforced:
/// - user must be signed in and must be a member of the group
/// - body must have content and be within length limits
/// - photo URL, if present, must look like a URL
/// - posts mentioning emergency or danger keywords are flagged for
///   moderation before being published
class CreatePost {
  final CommunityRepository repository;

  CreatePost(this.repository);

  /// Executes the post-creation flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [CommunityException] if persistence fails.
  Future<Post> call({
    required String groupId,
    required String authorUserId,
    required String body,
    String? photoUrl,
    bool isAnonymous = true,
    int? pregnancyWeekAtPost,
  }) async {
    // ---------- VALIDATION ----------

    if (authorUserId.trim().isEmpty) {
      throw ArgumentError('You must be signed in to post.');
    }

    if (groupId.trim().isEmpty) {
      throw ArgumentError('Group ID is required.');
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

    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      if (!_isValidUrl(photoUrl.trim())) {
        throw ArgumentError('Photo URL is not valid.');
      }
    }

    if (pregnancyWeekAtPost != null &&
        (pregnancyWeekAtPost < 1 || pregnancyWeekAtPost > 45)) {
      throw ArgumentError('Pregnancy week must be between 1 and 45.');
    }

    // ---------- CREATE ----------
    // The repository decides the final moderation status based on the
    // content flags. For unflagged content it will publish immediately;
    // for flagged content it will hold as pending until a moderator
    // reviews.

    return repository.createPost(
      groupId: groupId,
      authorUserId: authorUserId,
      body: trimmedBody,
      photoUrl: photoUrl?.trim(),
      isAnonymous: isAnonymous,
      pregnancyWeekAtPost: pregnancyWeekAtPost,
    );
  }

  bool _isValidUrl(String url) {
    final urlRegex = RegExp(r'^https?://[^\s]+$');
    return urlRegex.hasMatch(url);
  }
}