import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reply.dart';

/// Data model for the Reply entity.
///
/// Extends the pure entity with Firestore serialisation logic.
class ReplyModel extends Reply {
  const ReplyModel({
    required super.replyId,
    required super.postId,
    required super.authorUserId,
    required super.body,
    super.isAnonymous,
    super.moderationStatus,
    super.likesCount,
    required super.createdAt,
  });

  factory ReplyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ReplyModel(
      replyId: doc.id,
      postId: data['post_id'] as String? ?? '',
      authorUserId: data['author_user_id'] as String? ?? '',
      body: data['body'] as String? ?? '',
      isAnonymous: data['is_anonymous'] as bool? ?? true,
      moderationStatus: _statusFromString(
        data['moderation_status'] as String?,
      ),
      likesCount: (data['likes_count'] as num?)?.toInt() ?? 0,
      createdAt: _timestampToDateTime(data['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'post_id': postId,
      'author_user_id': authorUserId,
      'body': body,
      'is_anonymous': isAnonymous,
      'moderation_status': _statusToString(moderationStatus),
      'likes_count': likesCount,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory ReplyModel.fromEntity(Reply reply) {
    return ReplyModel(
      replyId: reply.replyId,
      postId: reply.postId,
      authorUserId: reply.authorUserId,
      body: reply.body,
      isAnonymous: reply.isAnonymous,
      moderationStatus: reply.moderationStatus,
      likesCount: reply.likesCount,
      createdAt: reply.createdAt,
    );
  }

  // ---------- ENUM SERIALISATION ----------

  static ReplyModerationStatus _statusFromString(String? value) {
    switch (value) {
      case 'hidden':
        return ReplyModerationStatus.hidden;
      case 'removed':
        return ReplyModerationStatus.removed;
      case 'approved':
      default:
        return ReplyModerationStatus.approved;
    }
  }

  static String _statusToString(ReplyModerationStatus status) {
    switch (status) {
      case ReplyModerationStatus.approved:
        return 'approved';
      case ReplyModerationStatus.hidden:
        return 'hidden';
      case ReplyModerationStatus.removed:
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