import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post.dart';

/// Data model for the Post entity.
///
/// Extends the pure entity with Firestore serialisation logic.
class PostModel extends Post {
  const PostModel({
    required super.postId,
    required super.groupId,
    required super.authorUserId,
    required super.body,
    super.photoUrl,
    super.isAnonymous,
    super.moderationStatus,
    super.likesCount,
    super.repliesCount,
    super.pregnancyWeekAtPost,
    required super.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PostModel(
      postId: doc.id,
      groupId: data['group_id'] as String? ?? '',
      authorUserId: data['author_user_id'] as String? ?? '',
      body: data['body'] as String? ?? '',
      photoUrl: data['photo_url'] as String?,
      isAnonymous: data['is_anonymous'] as bool? ?? true,
      moderationStatus: _statusFromString(
        data['moderation_status'] as String?,
      ),
      likesCount: (data['likes_count'] as num?)?.toInt() ?? 0,
      repliesCount: (data['replies_count'] as num?)?.toInt() ?? 0,
      pregnancyWeekAtPost:
      (data['pregnancy_week_at_post'] as num?)?.toInt(),
      createdAt: _timestampToDateTime(data['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'group_id': groupId,
      'author_user_id': authorUserId,
      'body': body,
      'photo_url': photoUrl,
      'is_anonymous': isAnonymous,
      'moderation_status': _statusToString(moderationStatus),
      'likes_count': likesCount,
      'replies_count': repliesCount,
      'pregnancy_week_at_post': pregnancyWeekAtPost,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      postId: post.postId,
      groupId: post.groupId,
      authorUserId: post.authorUserId,
      body: post.body,
      photoUrl: post.photoUrl,
      isAnonymous: post.isAnonymous,
      moderationStatus: post.moderationStatus,
      likesCount: post.likesCount,
      repliesCount: post.repliesCount,
      pregnancyWeekAtPost: post.pregnancyWeekAtPost,
      createdAt: post.createdAt,
    );
  }

  // ---------- ENUM SERIALISATION ----------

  static ModerationStatus _statusFromString(String? value) {
    switch (value) {
      case 'approved':
        return ModerationStatus.approved;
      case 'hidden':
        return ModerationStatus.hidden;
      case 'removed':
        return ModerationStatus.removed;
      case 'pending':
      default:
        return ModerationStatus.pending;
    }
  }

  static String _statusToString(ModerationStatus status) {
    switch (status) {
      case ModerationStatus.pending:
        return 'pending';
      case ModerationStatus.approved:
        return 'approved';
      case ModerationStatus.hidden:
        return 'hidden';
      case ModerationStatus.removed:
        return 'removed';
    }
  }

  // ---------- TIMESTAMP HELPER ----------

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}