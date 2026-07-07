/// Represents a scheduled or completed antenatal appointment.
///
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `appointments` collection in the ERD.
class Appointment {
  final String appointmentId;
  final String userId;
  final String clinicId;
  final DateTime scheduledAt;
  final VisitType visitType;
  final bool reminderSent;
  final bool attended;
  final String? notes;

  const Appointment({
    required this.appointmentId,
    required this.userId,
    required this.clinicId,
    required this.scheduledAt,
    required this.visitType,
    this.reminderSent = false,
    this.attended = false,
    this.notes,
  });

  /// True if this appointment is in the future.
  bool get isUpcoming =>
      scheduledAt.isAfter(DateTime.now()) && !attended;

  /// True if this appointment is in the past and was missed.
  bool get wasMissed =>
      scheduledAt.isBefore(DateTime.now()) && !attended;

  Appointment copyWith({
    String? appointmentId,
    String? userId,
    String? clinicId,
    DateTime? scheduledAt,
    VisitType? visitType,
    bool? reminderSent,
    bool? attended,
    String? notes,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      userId: userId ?? this.userId,
      clinicId: clinicId ?? this.clinicId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      visitType: visitType ?? this.visitType,
      reminderSent: reminderSent ?? this.reminderSent,
      attended: attended ?? this.attended,
      notes: notes ?? this.notes,
    );
  }
}

/// Category of clinic visit.
enum VisitType {
  antenatalCheckup,
  ultrasoundScan,
  bloodTest,
  vaccination,
  consultation,
  emergency,
  postnatalCheckup,
  other,
}