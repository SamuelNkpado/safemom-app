import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/danger_check.dart';

/// Data model for the DangerCheck entity.
///
/// Extends the pure entity with Firestore serialisation logic.
class DangerCheckModel extends DangerCheck {
  const DangerCheckModel({
    required super.checkId,
    required super.userId,
    required super.answers,
    required super.riskLevel,
    required super.recommendation,
    super.actionTaken,
    required super.completedAt,
  });

  /// Build a model from a Firestore document snapshot.
  factory DangerCheckModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Firestore returns Map<String, dynamic>; we know each value is a String.
    final rawAnswers = data['answers'] as Map<String, dynamic>? ?? {};
    final answers = <String, String>{
      for (final entry in rawAnswers.entries)
        entry.key: entry.value?.toString() ?? '',
    };

    return DangerCheckModel(
      checkId: doc.id,
      userId: data['user_id'] as String? ?? '',
      answers: answers,
      riskLevel: _riskFromString(data['risk_level'] as String?),
      recommendation: data['recommendation'] as String? ?? '',
      actionTaken: _actionFromString(data['action_taken'] as String?),
      completedAt: _timestampToDateTime(data['completed_at']) ?? DateTime.now(),
    );
  }

  /// Convert this model to a Firestore-writable map.
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'answers': answers,
      'risk_level': _riskToString(riskLevel),
      'recommendation': recommendation,
      'action_taken': actionTaken != null ? _actionToString(actionTaken!) : null,
      'completed_at': Timestamp.fromDate(completedAt),
    };
  }

  /// Convert a pure DangerCheck entity to a model.
  factory DangerCheckModel.fromEntity(DangerCheck check) {
    return DangerCheckModel(
      checkId: check.checkId,
      userId: check.userId,
      answers: check.answers,
      riskLevel: check.riskLevel,
      recommendation: check.recommendation,
      actionTaken: check.actionTaken,
      completedAt: check.completedAt,
    );
  }

  // ---------- ENUM SERIALISATION ----------

  static RiskLevel _riskFromString(String? value) {
    switch (value) {
      case 'high':
        return RiskLevel.high;
      case 'medium':
        return RiskLevel.medium;
      case 'low':
      default:
        return RiskLevel.low;
    }
  }

  static String _riskToString(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'low';
      case RiskLevel.medium:
        return 'medium';
      case RiskLevel.high:
        return 'high';
    }
  }

  static ActionTaken? _actionFromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'dismissed':
        return ActionTaken.dismissed;
      case 'contacted_clinic':
        return ActionTaken.contactedClinic;
      case 'requested_emergency':
        return ActionTaken.requestedEmergency;
      case 'waited_and_monitored':
        return ActionTaken.waitedAndMonitored;
      default:
        return null;
    }
  }

  static String _actionToString(ActionTaken action) {
    switch (action) {
      case ActionTaken.dismissed:
        return 'dismissed';
      case ActionTaken.contactedClinic:
        return 'contacted_clinic';
      case ActionTaken.requestedEmergency:
        return 'requested_emergency';
      case ActionTaken.waitedAndMonitored:
        return 'waited_and_monitored';
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