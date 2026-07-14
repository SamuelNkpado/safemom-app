import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/symptom_log.dart';

/// Data model for the SymptomLog entity.
///
/// Extends the pure entity with Firestore serialisation logic.
class SymptomLogModel extends SymptomLog {
  const SymptomLogModel({
    required super.symptomId,
    required super.userId,
    required super.symptomType,
    required super.severity,
    super.note,
    required super.pregnancyWeek,
    required super.loggedAt,
    super.flaggedAsDanger,
  });

  /// Build a model from a Firestore document snapshot.
  factory SymptomLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SymptomLogModel(
      symptomId: doc.id,
      userId: data['user_id'] as String? ?? '',
      symptomType: _typeFromString(data['symptom_type'] as String?),
      severity: (data['severity'] as num?)?.toInt() ?? 1,
      note: data['note'] as String?,
      pregnancyWeek: (data['pregnancy_week'] as num?)?.toInt() ?? 1,
      loggedAt: _timestampToDateTime(data['logged_at']) ?? DateTime.now(),
      flaggedAsDanger: data['flagged_as_danger'] as bool? ?? false,
    );
  }

  /// Convert this model to a Firestore-writable map.
  ///
  /// Field names match the ERD (snake_case).
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'symptom_type': _typeToString(symptomType),
      'severity': severity,
      'note': note,
      'pregnancy_week': pregnancyWeek,
      'logged_at': Timestamp.fromDate(loggedAt),
      'flagged_as_danger': flaggedAsDanger,
    };
  }

  /// Convert a pure SymptomLog entity to a model.
  factory SymptomLogModel.fromEntity(SymptomLog symptom) {
    return SymptomLogModel(
      symptomId: symptom.symptomId,
      userId: symptom.userId,
      symptomType: symptom.symptomType,
      severity: symptom.severity,
      note: symptom.note,
      pregnancyWeek: symptom.pregnancyWeek,
      loggedAt: symptom.loggedAt,
      flaggedAsDanger: symptom.flaggedAsDanger,
    );
  }

  // ---------- ENUM SERIALISATION ----------

  static SymptomType _typeFromString(String? value) {
    switch (value) {
      case 'back_pain':
        return SymptomType.backPain;
      case 'nausea':
        return SymptomType.nausea;
      case 'fatigue':
        return SymptomType.fatigue;
      case 'swelling':
        return SymptomType.swelling;
      case 'headache':
        return SymptomType.headache;
      case 'cramping':
        return SymptomType.cramping;
      case 'bleeding':
        return SymptomType.bleeding;
      case 'dizziness':
        return SymptomType.dizziness;
      case 'contractions':
        return SymptomType.contractions;
      case 'reduced_fetal_movement':
        return SymptomType.reducedFetalMovement;
      case 'other':
      default:
        return SymptomType.other;
    }
  }

  static String _typeToString(SymptomType type) {
    switch (type) {
      case SymptomType.backPain:
        return 'back_pain';
      case SymptomType.nausea:
        return 'nausea';
      case SymptomType.fatigue:
        return 'fatigue';
      case SymptomType.swelling:
        return 'swelling';
      case SymptomType.headache:
        return 'headache';
      case SymptomType.cramping:
        return 'cramping';
      case SymptomType.bleeding:
        return 'bleeding';
      case SymptomType.dizziness:
        return 'dizziness';
      case SymptomType.contractions:
        return 'contractions';
      case SymptomType.reducedFetalMovement:
        return 'reduced_fetal_movement';
      case SymptomType.other:
        return 'other';
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