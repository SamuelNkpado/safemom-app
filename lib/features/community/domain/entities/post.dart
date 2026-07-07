/// Represents a single post inside a community group.
///
/// Posts can be anonymous (author identity hidden) and go through
/// moderation if they mention emergencies or danger signs.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `posts` collection in the ERD.
class Post {
  final String postId;
  final String groupId;
  final String authorUserId;
  final String body;
  final String? photoUrl;
  final bool isAnonymous;
  final ModerationStatus moderationStatus;
  final int likesCount;
  final int repliesCount;
  final int? pregnancyWeekAtPost;
  final DateTime createdAt;

  const Post({
    required this.postId,
    required this.groupId,
    required this.authorUserId,
    required this.body,
    this.photoUrl,
    this.isAnonymous = true,
    this.moderationStatus = ModerationStatus.pending,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.pregnancyWeekAtPost,
    required this.createdAt,
  });

  /// True if this post is publicly visible.
  bool get isPublished => moderationStatus == ModerationStatus.approved;

  /// True if this post is awaiting moderator review.
  bool get isPending => moderationStatus == ModerationStatus.pending;

  Post copyWith({
    String? postId,
    String? groupId,
    String? authorUserId,
    String? body,
    String? photoUrl,
    bool? isAnonymous,
    ModerationStatus? moderationStatus,
    int? likesCount,
    int? repliesCount,
    int? pregnancyWeekAtPost,
    DateTime? createdAt,
  }) {
    return Post(
      postId: postId ?? this.postId,
      groupId: groupId ?? this.groupId,
      authorUserId: authorUserId ?? this.authorUserId,
      body: body ?? this.body,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      pregnancyWeekAtPost: pregnancyWeekAtPost ?? this.pregnancyWeekAtPost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Content moderation state.
enum ModerationStatus {
  pending,
  approved,
  hidden,
  removed,
}