import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/entities/saved_tip.dart';

/// Data model for the SavedTip entity.
///
/// Junction between users and weekly tips — tracks user bookmarks.
class SavedTipModel extends SavedTip {
  const SavedTipModel({
    required super.savedId,
    required super.userId,
    required super.tipId,
    required super.savedAt,
    super.note,
  });

  factory SavedTipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SavedTipModel(
      savedId: doc.id,
      userId: data['user_id'] as String? ?? '',
      tipId: data['tip_id'] as String? ?? '',
      savedAt: _timestampToDateTime(data['saved_at']) ?? DateTime.now(),
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'tip_id': tipId,
      'saved_at': Timestamp.fromDate(savedAt),
      'note': note,
    };
  }

  factory SavedTipModel.fromEntity(SavedTip savedTip) {
    return SavedTipModel(
      savedId: savedTip.savedId,
      userId: savedTip.userId,
      tipId: savedTip.tipId,
      savedAt: savedTip.savedAt,
      note: savedTip.note,
    );
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