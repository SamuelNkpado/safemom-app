import '../entities/post.dart';
import '../repositories/community_repository.dart';

/// Business operation: fetch posts inside a community group.
///
/// Applies pagination and filters out any posts that are not published
/// (still pending moderation, hidden, or removed).
///
/// The repository returns raw posts; this use case decides which ones
/// the caller should actually see.
class GetGroupPosts {
  final CommunityRepository repository;

  GetGroupPosts(this.repository);

  /// Executes the fetch.
  ///
  /// [limit] caps how many posts are returned per call (default 20).
  /// [before] pages backwards — pass the createdAt of the oldest post
  /// you already have to fetch the next page.
  ///
  /// Throws [ArgumentError] on invalid input.
  Future<List<Post>> call({
    required String groupId,
    int limit = 20,
    DateTime? before,
  }) async {
    // ---------- VALIDATION ----------

    if (groupId.trim().isEmpty) {
      throw ArgumentError('Group ID is required.');
    }

    if (limit < 1 || limit > 100) {
      throw ArgumentError('Limit must be between 1 and 100.');
    }

    // ---------- FETCH ----------

    final posts = await repository.getGroupPosts(
      groupId: groupId,
      limit: limit,
      before: before,
    );

    // ---------- FILTER TO PUBLISHED ONLY ----------

    return posts.where((post) => post.isPublished).toList();
  }
}