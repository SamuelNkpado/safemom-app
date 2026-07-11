import '../../../../core/entities/weekly_tip.dart';
import '../../../../core/entities/saved_tip.dart';

/// Contract for weekly tip and saved-tip operations.
///
/// The data layer implements this using Firestore. Weekly tips are
/// curated content (admin-written); saved tips are user-owned bookmarks.
abstract class WeeklyTipRepository {
  // ---------- WEEKLY TIPS (read-only, curated) ----------

  /// Fetch the tip for a specific pregnancy week in the given language.
  ///
  /// Returns null if no tip exists for that week in that language.
  Future<WeeklyTip?> getTipForWeek({
    required int week,
    required String languageCode,
  });

  /// Fetch all tips for a given trimester range in a language.
  Future<List<WeeklyTip>> getTipsForRange({
    required int startWeek,
    required int endWeek,
    required String languageCode,
  });

  // ---------- SAVED TIPS (user-owned bookmarks) ----------

  /// Save a tip for later reading.
  ///
  /// If the user has already saved this tip, the existing SavedTip is
  /// returned unchanged.
  Future<SavedTip> saveTip({
    required String userId,
    required String tipId,
    String? note,
  });

  /// Fetch all tips a user has saved, most recent first.
  Future<List<SavedTip>> getUserSavedTips(String userId);

  /// Remove a saved tip.
  Future<void> unsaveTip(String savedId);

  /// Check whether the user has already saved a specific tip.
  Future<bool> hasSavedTip({
    required String userId,
    required String tipId,
  });
}

/// Base exception for weekly tip operations.
class WeeklyTipException implements Exception {
  final String message;
  final String? code;

  const WeeklyTipException(this.message, {this.code});

  @override
  String toString() => 'WeeklyTipException($code): $message';
}