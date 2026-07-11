import '../../../../core/entities/saved_tip.dart';
import '../repositories/weekly_tip_repository.dart';

/// Business operation: save a weekly tip for later reading.
///
/// Rules enforced:
/// - user must be signed in
/// - tip ID must be provided
/// - optional note has a length limit
/// - if the user has already saved this tip, we return the existing
///   SavedTip rather than creating a duplicate
class SaveTip {
  final WeeklyTipRepository repository;

  SaveTip(this.repository);

  /// Executes the save flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [WeeklyTipException] if persistence fails.
  Future<SavedTip> call({
    required String userId,
    required String tipId,
    String? note,
  }) async {
    // ---------- VALIDATION ----------

    if (userId.trim().isEmpty) {
      throw ArgumentError('You must be signed in to save tips.');
    }

    if (tipId.trim().isEmpty) {
      throw ArgumentError('Tip ID is required.');
    }

    if (note != null && note.length > 300) {
      throw ArgumentError('Note must be under 300 characters.');
    }

    // ---------- SAVE ----------
    // The repository handles the "already saved" case idempotently.

    return repository.saveTip(
      userId: userId,
      tipId: tipId,
      note: note?.trim(),
    );
  }
}