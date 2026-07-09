import '../entities/emergency_request.dart';
import '../repositories/emergency_repository.dart';

/// Business operation: cancel an active emergency request.
///
/// Rules enforced:
/// - The request must exist
/// - Only the user who created the request can cancel it (also
///   enforced by Firestore security rules)
/// - Requests that have already been resolved (arrived, cancelled,
///   failed) cannot be cancelled again
class CancelEmergency {
  final EmergencyRepository repository;

  CancelEmergency(this.repository);

  /// Executes the cancellation.
  ///
  /// Throws [ArgumentError] if the request ID or user ID is missing.
  /// Throws [StateError] if the request cannot be cancelled in its
  /// current state (e.g. already resolved).
  /// Throws [EmergencyException] if persistence fails.
  Future<void> call({
    required String requestId,
    required String userId,
  }) async {
    // ---------- VALIDATION ----------

    if (requestId.trim().isEmpty) {
      throw ArgumentError('Request ID is required.');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError('User must be signed in to cancel a request.');
    }

    // ---------- LOAD AND VERIFY ----------

    final request = await repository.getRequest(requestId);

    if (request == null) {
      throw StateError('This emergency request no longer exists.');
    }

    if (request.userId != userId) {
      throw StateError('You can only cancel your own emergency requests.');
    }

    if (!request.isActive) {
      throw StateError(
        'This request cannot be cancelled — it is already '
            '${_statusLabel(request.status)}.',
      );
    }

    // ---------- CANCEL ----------

    return repository.cancelRequest(requestId);
  }

  String _statusLabel(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.pending:
        return 'pending';
      case EmergencyStatus.dispatched:
        return 'dispatched';
      case EmergencyStatus.enRoute:
        return 'en route';
      case EmergencyStatus.arrived:
        return 'complete';
      case EmergencyStatus.cancelled:
        return 'already cancelled';
      case EmergencyStatus.failed:
        return 'failed';
    }
  }
}