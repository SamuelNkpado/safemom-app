/// Represents a single symptom entry logged by a user.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `symptom_logs` collection in the ERD.
class SymptomLog {
  final String symptomId;
  final String userId;
  final SymptomType symptomType;
  final int severity;
  final String? note;
  final int pregnancyWeek;
  final DateTime loggedAt;
  final bool flaggedAsDanger;

  const SymptomLog({
    required this.symptomId,
    required this.userId,
    required this.symptomType,
    required this.severity,
    this.note,
    required this.pregnancyWeek,
    required this.loggedAt,
    this.flaggedAsDanger = false,
  });

  SymptomLog copyWith({
    String? symptomId,
    String? userId,
    SymptomType? symptomType,
    int? severity,
    String? note,
    int? pregnancyWeek,
    DateTime? loggedAt,
    bool? flaggedAsDanger,
  }) {
    return SymptomLog(
      symptomId: symptomId ?? this.symptomId,
      userId: userId ?? this.userId,
      symptomType: symptomType ?? this.symptomType,
      severity: severity ?? this.severity,
      note: note ?? this.note,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      loggedAt: loggedAt ?? this.loggedAt,
      flaggedAsDanger: flaggedAsDanger ?? this.flaggedAsDanger,
    );
  }
}

/// Categories of symptoms trackable in SafeMom.
enum SymptomType {
  backPain,
  nausea,
  fatigue,
  swelling,
  headache,
  cramping,
  bleeding,
  dizziness,
  contractions,
  reducedFetalMovement,
  other,
}