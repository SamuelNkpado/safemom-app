import '../repositories/appointment_repository.dart';

/// Business operation: mark an appointment as attended.
///
/// Called after the user confirms they went to their clinic visit.
/// Rules enforced:
/// - appointment ID must be provided
/// - user must be signed in
/// - the appointment must exist and belong to the user
class MarkAppointmentAttended {
  final AppointmentRepository repository;

  MarkAppointmentAttended(this.repository);

  /// Executes the mark-attended flow.
  ///
  /// Throws [ArgumentError] on invalid input.
  /// Throws [StateError] if the appointment does not exist or is not
  /// owned by the user.
  /// Throws [AppointmentException] if the update fails.
  Future<void> call({
    required String appointmentId,
    required String userId,
  }) async {
    // ---------- VALIDATION ----------

    if (appointmentId.trim().isEmpty) {
      throw ArgumentError('Appointment ID is required.');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError('You must be signed in to update appointments.');
    }

    // ---------- OWNERSHIP GUARD ----------

    final appointment = await repository.getAppointment(appointmentId);

    if (appointment == null) {
      throw StateError('This appointment no longer exists.');
    }

    if (appointment.userId != userId) {
      throw StateError('You can only update your own appointments.');
    }

    if (appointment.attended) {
      // Already marked — nothing to do. Idempotent behaviour.
      return;
    }

    // ---------- UPDATE ----------

    return repository.markAttended(appointmentId);
  }
}