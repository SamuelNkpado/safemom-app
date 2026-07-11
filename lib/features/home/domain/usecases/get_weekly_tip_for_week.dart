import '../../../../core/entities/weekly_tip.dart';
import '../repositories/weekly_tip_repository.dart';

/// Business operation: fetch the weekly tip for the user's current
/// pregnancy week in their preferred language.
///
/// Falls back to English if a tip is not available in the user's
/// requested language.
class GetWeeklyTipForWeek {
  final WeeklyTipRepository repository;

  GetWeeklyTipForWeek(this.repository);

  /// Executes the fetch.
  ///
  /// Returns null if no tip exists for that week in either the
  /// preferred language or the English fallback.
  ///
  /// Throws [ArgumentError] on invalid input.
  Future<WeeklyTip?> call({
    required int week,
    required String languageCode,
  }) async {
    // ---------- VALIDATION ----------

    if (week < 1 || week > 45) {
      throw ArgumentError('Week must be between 1 and 45.');
    }

    final normalisedLang = languageCode.trim().toLowerCase();

    if (normalisedLang.isEmpty) {
      throw ArgumentError('Language code is required.');
    }

    // ---------- PRIMARY LOOKUP ----------

    final tip = await repository.getTipForWeek(
      week: week,
      languageCode: normalisedLang,
    );

    if (tip != null) return tip;

    // ---------- FALLBACK TO ENGLISH ----------

    if (normalisedLang != 'en') {
      return repository.getTipForWeek(week: week, languageCode: 'en');
    }

    return null;
  }
}