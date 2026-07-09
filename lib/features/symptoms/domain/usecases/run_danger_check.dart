import '../entities/danger_check.dart';
import '../repositories/symptom_repository.dart';

/// Business operation: run a danger-sign self-check against user answers.
///
/// Takes a map of question-to-answer values and produces a risk
/// assessment (low, medium, high) along with a recommendation string.
///
/// This is a screening tool, not a diagnosis. The risk logic uses
/// simple rules based on the number and severity of "yes" answers to
/// key danger-sign questions.
///
/// The check is persisted regardless of outcome so the user has a
/// historical record and so patterns can be surfaced later.
class RunDangerCheck {
  final SymptomRepository repository;

  RunDangerCheck(this.repository);

  /// Executes the danger check.
  ///
  /// [answers] is a map keyed by question ID; each value is one of
  /// "yes", "no", "unsure".
  ///
  /// Throws [ArgumentError] if inputs are invalid.
  Future<DangerCheck> call({
    required String checkId,
    required String userId,
    required Map<String, String> answers,
    DateTime? completedAt,
  }) async {
    // ---------- VALIDATION ----------

    if (userId.trim().isEmpty) {
      throw ArgumentError('User must be signed in to run a danger check.');
    }

    if (answers.isEmpty) {
      throw ArgumentError('At least one question must be answered.');
    }

    for (final entry in answers.entries) {
      final value = entry.value.toLowerCase().trim();
      if (value != 'yes' && value != 'no' && value != 'unsure') {
        throw ArgumentError(
          'Answer for "${entry.key}" must be "yes", "no", or "unsure".',
        );
      }
    }

    // ---------- RISK ASSESSMENT ----------

    final yesCount = answers.values
        .where((a) => a.toLowerCase().trim() == 'yes')
        .length;

    final unsureCount = answers.values
        .where((a) => a.toLowerCase().trim() == 'unsure')
        .length;

    final riskLevel = _computeRiskLevel(
      yesCount: yesCount,
      unsureCount: unsureCount,
      totalQuestions: answers.length,
    );

    final recommendation = _buildRecommendation(riskLevel);

    // ---------- CREATE AND PERSIST ----------

    final check = DangerCheck(
      checkId: checkId,
      userId: userId,
      answers: Map<String, String>.from(answers),
      riskLevel: riskLevel,
      recommendation: recommendation,
      actionTaken: null,
      completedAt: completedAt ?? DateTime.now(),
    );

    await repository.saveDangerCheck(check);
    return check;
  }

  /// Simple scoring:
  /// - Any 2+ "yes" answers → HIGH risk
  /// - 1 "yes" or 3+ "unsure" answers → MEDIUM risk
  /// - Otherwise → LOW risk
  RiskLevel _computeRiskLevel({
    required int yesCount,
    required int unsureCount,
    required int totalQuestions,
  }) {
    if (yesCount >= 2) return RiskLevel.high;
    if (yesCount == 1 || unsureCount >= 3) return RiskLevel.medium;
    return RiskLevel.low;
  }

  String _buildRecommendation(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return 'Please seek medical attention immediately. '
            'Contact your clinic or use the emergency button in this app.';
      case RiskLevel.medium:
        return 'Your symptoms may need attention. '
            'Please contact your clinic within the next 24 hours.';
      case RiskLevel.low:
        return 'Your symptoms appear normal for pregnancy. '
            'Continue monitoring and log any changes.';
    }
  }
}