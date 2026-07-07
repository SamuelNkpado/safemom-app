/// Represents a weekly tip saved by a user.
///
/// Junction entity resolving the many-to-many relationship between
/// users and weekly_tips.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `saved_tips` collection in the ERD.
class SavedTip {
  final String savedId;
  final String userId;
  final String tipId;
  final DateTime savedAt;
  final String? note;

  const SavedTip({
    required this.savedId,
    required this.userId,
    required this.tipId,
    required this.savedAt,
    this.note,
  });

  SavedTip copyWith({
    String? savedId,
    String? userId,
    String? tipId,
    DateTime? savedAt,
    String? note,
  }) {
    return SavedTip(
      savedId: savedId ?? this.savedId,
      userId: userId ?? this.userId,
      tipId: tipId ?? this.tipId,
      savedAt: savedAt ?? this.savedAt,
      note: note ?? this.note,
    );
  }
}