/// Represents a single completed run through the danger-sign checker.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `danger_checks` collection in the ERD.
class DangerCheck {
  final String checkId;
  final String userId;
  final Map<String, String> answers;
  final RiskLevel riskLevel;
  final String recommendation;
  final ActionTaken? actionTaken;
  final DateTime completedAt;

  const DangerCheck({
    required this.checkId,
    required this.userId,
    required this.answers,
    required this.riskLevel,
    required this.recommendation,
    this.actionTaken,
    required this.completedAt,
  });

  DangerCheck copyWith({
    String? checkId,
    String? userId,
    Map<String, String>? answers,
    RiskLevel? riskLevel,
    String? recommendation,
    ActionTaken? actionTaken,
    DateTime? completedAt,
  }) {
    return DangerCheck(
      checkId: checkId ?? this.checkId,
      userId: userId ?? this.userId,
      answers: answers ?? this.answers,
      riskLevel: riskLevel ?? this.riskLevel,
      recommendation: recommendation ?? this.recommendation,
      actionTaken: actionTaken ?? this.actionTaken,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Risk assessment produced by the danger-sign checker.
enum RiskLevel {
  low,
  medium,
  high,
}

/// What the user chose to do after seeing the recommendation.
enum ActionTaken {
  dismissed,
  contactedClinic,
  requestedEmergency,
  waitedAndMonitored,
}