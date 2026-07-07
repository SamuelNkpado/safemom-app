/// Represents a reply to a community post.
///
/// Replies inherit the same moderation pattern as posts and can also
/// be anonymous.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `replies` collection in the ERD.
class Reply {
  final String replyId;
  final String postId;
  final String authorUserId;
  final String body;
  final bool isAnonymous;
  final ReplyModerationStatus moderationStatus;
  final int likesCount;
  final DateTime createdAt;

  const Reply({
    required this.replyId,
    required this.postId,
    required this.authorUserId,
    required this.body,
    this.isAnonymous = true,
    this.moderationStatus = ReplyModerationStatus.approved,
    this.likesCount = 0,
    required this.createdAt,
  });

  /// True if this reply is publicly visible.
  bool get isPublished => moderationStatus == ReplyModerationStatus.approved;

  Reply copyWith({
    String? replyId,
    String? postId,
    String? authorUserId,
    String? body,
    bool? isAnonymous,
    ReplyModerationStatus? moderationStatus,
    int? likesCount,
    DateTime? createdAt,
  }) {
    return Reply(
      replyId: replyId ?? this.replyId,
      postId: postId ?? this.postId,
      authorUserId: authorUserId ?? this.authorUserId,
      body: body ?? this.body,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Reply moderation state.
///
/// Kept separate from post ModerationStatus so the two enums can evolve
/// independently — e.g., replies may never need a "pending" state.
enum ReplyModerationStatus {
  approved,
  hidden,
  removed,
}