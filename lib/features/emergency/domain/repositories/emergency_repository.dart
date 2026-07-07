import '../entities/emergency_request.dart';

/// Contract for emergency dispatch operations.
///
/// The data layer implements this using Firestore, plus integrations
/// with partner ambulance dispatch services (out of scope for the
/// current prototype but reflected in the interface).
///
/// Because emergency requests are the highest-stakes operation in the
/// app, all methods are expected to fail gracefully with user-facing
/// error messages, and to fall back to direct clinic contact if
/// automated dispatch is unavailable.
abstract class EmergencyRepository {
  /// Create a new emergency request for the current user.
  ///
  /// This will attempt to auto-dispatch a partner ambulance and notify
  /// the user's linked partner. Returns the created request with its
  /// initial status.
  ///
  /// Throws [EmergencyException] on failure. The presentation layer
  /// should always surface a fallback (call clinic directly) if this fails.
  Future<EmergencyRequest> createRequest({
    required String userId,
    required String clinicId,
    required double latitude,
    required double longitude,
  });

  /// Cancel an active emergency request.
  ///
  /// Only the user who created the request can cancel it.
  Future<void> cancelRequest(String requestId);

  /// Fetch a single emergency request by ID.
  Future<EmergencyRequest?> getRequest(String requestId);

  /// Fetch a user's history of emergency requests, most recent first.
  Future<List<EmergencyRequest>> getUserRequests(String userId);

  /// Fetch the user's currently active emergency request, if any.
  Future<EmergencyRequest?> getActiveRequest(String userId);

  /// Real-time stream of a single emergency request.
  ///
  /// Used by the emergency dispatch screen to show live ETA updates,
  /// driver assignment, and status changes.
  Stream<EmergencyRequest> watchRequest(String requestId);

  /// Manually update the status of a request.
  ///
  /// In production this would come from the dispatch provider webhook,
  /// but for the prototype the app may update status directly.
  Future<void> updateStatus({
    required String requestId,
    required EmergencyStatus newStatus,
    int? etaMinutes,
    String? driverName,
    String? driverPhone,
    String? vehiclePlate,
  });

  /// Mark that the user's partner has been notified of the emergency.
  Future<void> markPartnerNotified(String requestId);
}

/// Base exception for emergency operations.
class EmergencyException implements Exception {
  final String message;
  final String? code;

  const EmergencyException(this.message, {this.code});

  @override
  String toString() => 'EmergencyException($code): $message';
}