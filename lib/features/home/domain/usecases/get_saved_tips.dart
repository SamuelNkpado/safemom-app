import '../../../../core/entities/saved_tip.dart';
import '../repositories/weekly_tip_repository.dart';

/// Business operation: fetch all tips the user has saved.
///
/// Returned sorted most recent first — the repository already applies
/// this order but we assert it here in case the underlying source changes.
class GetSavedTips {
  final WeeklyTipRepository repository;

  GetSavedTips(this.repository);

  /// Executes the fetch.
  ///
  /// Throws [ArgumentError] if userId is empty.
  Future<List<SavedTip>> call({required String userId}) async {
    // ---------- VALIDATION ----------

    if (userId.trim().isEmpty) {
      throw ArgumentError('You must be signed in to view saved tips.');
    }

    // ---------- FETCH ----------

    final tips = await repository.getUserSavedTips(userId);

    // ---------- SORT MOST RECENT FIRST ----------

    tips.sort((a, b) => b.savedAt.compareTo(a.savedAt));

    return tips;
  }
}