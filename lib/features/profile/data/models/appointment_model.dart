import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/appointment.dart';

/// Data model for the Appointment entity.
///
/// Extends the pure entity with Firestore serialisation logic.
class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.appointmentId,
    required super.userId,
    required super.clinicId,
    required super.scheduledAt,
    required super.visitType,
    super.reminderSent,
    super.attended,
    super.notes,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return AppointmentModel(
      appointmentId: doc.id,
      userId: data['user_id'] as String? ?? '',
      clinicId: data['clinic_id'] as String? ?? '',
      scheduledAt: _timestampToDateTime(data['scheduled_at']) ?? DateTime.now(),
      visitType: _visitTypeFromString(data['visit_type'] as String?),
      reminderSent: data['reminder_sent'] as bool? ?? false,
      attended: data['attended'] as bool? ?? false,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'clinic_id': clinicId,
      'scheduled_at': Timestamp.fromDate(scheduledAt),
      'visit_type': _visitTypeToString(visitType),
      'reminder_sent': reminderSent,
      'attended': attended,
      'notes': notes,
    };
  }

  factory AppointmentModel.fromEntity(Appointment appointment) {
    return AppointmentModel(
      appointmentId: appointment.appointmentId,
      userId: appointment.userId,
      clinicId: appointment.clinicId,
      scheduledAt: appointment.scheduledAt,
      visitType: appointment.visitType,
      reminderSent: appointment.reminderSent,
      attended: appointment.attended,
      notes: appointment.notes,
    );
  }

  // ---------- ENUM SERIALISATION ----------

  static VisitType _visitTypeFromString(String? value) {
    switch (value) {
      case 'antenatal_checkup':
        return VisitType.antenatalCheckup;
      case 'ultrasound_scan':
        return VisitType.ultrasoundScan;
      case 'blood_test':
        return VisitType.bloodTest;
      case 'vaccination':
        return VisitType.vaccination;
      case 'consultation':
        return VisitType.consultation;
      case 'emergency':
        return VisitType.emergency;
      case 'postnatal_checkup':
        return VisitType.postnatalCheckup;
      case 'other':
      default:
        return VisitType.other;
    }
  }

  static String _visitTypeToString(VisitType type) {
    switch (type) {
      case VisitType.antenatalCheckup:
        return 'antenatal_checkup';
      case VisitType.ultrasoundScan:
        return 'ultrasound_scan';
      case VisitType.bloodTest:
        return 'blood_test';
      case VisitType.vaccination:
        return 'vaccination';
      case VisitType.consultation:
        return 'consultation';
      case VisitType.emergency:
        return 'emergency';
      case VisitType.postnatalCheckup:
        return 'postnatal_checkup';
      case VisitType.other:
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