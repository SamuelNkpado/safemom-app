import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/emergency_request.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_firestore_datasource.dart';

/// Concrete implementation of [EmergencyRepository] backed by Firestore.
///
/// Delegates work to the Firestore datasource and translates
/// Firebase-specific exceptions into domain-level [EmergencyException]s.
///
/// Because emergency requests are the highest-stakes operation in the
/// app, error messages here are especially user-friendly — the UI will
/// always show these strings verbatim.
class EmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyFirestoreDatasource _datasource;

  EmergencyRepositoryImpl(this._datasource);

  // ---------- CREATE ----------

  @override
  Future<EmergencyRequest> createRequest({
    required String userId,
    required String clinicId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _datasource.createRequest(
        userId: userId,
        clinicId: clinicId,
        latitude: latitude,
        longitude: longitude,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- CANCEL ----------

  @override
  Future<void> cancelRequest(String requestId) async {
    try {
      await _datasource.cancelRequest(requestId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- READ ----------

  @override
  Future<EmergencyRequest?> getRequest(String requestId) async {
    try {
      return await _datasource.getRequest(requestId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<List<EmergencyRequest>> getUserRequests(String userId) async {
    try {
      return await _datasource.getUserRequests(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<EmergencyRequest?> getActiveRequest(String userId) async {
    try {
      return await _datasource.getActiveRequest(userId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Stream<EmergencyRequest> watchRequest(String requestId) {
    // Streams don't wrap errors the same way — the presentation layer
    // handles errors via the stream's onError callback.
    return _datasource.watchRequest(requestId);
  }

  // ---------- UPDATE ----------

  @override
  Future<void> updateStatus({
    required String requestId,
    required EmergencyStatus newStatus,
    int? etaMinutes,
    String? driverName,
    String? driverPhone,
    String? vehiclePlate,
  }) async {
    try {
      await _datasource.updateStatus(
        requestId: requestId,
        newStatus: newStatus,
        etaMinutes: etaMinutes,
        driverName: driverName,
        driverPhone: driverPhone,
        vehiclePlate: vehiclePlate,
      );
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  @override
  Future<void> markPartnerNotified(String requestId) async {
    try {
      await _datasource.markPartnerNotified(requestId);
    } on FirebaseException catch (e) {
      throw _translateException(e);
    }
  }

  // ---------- ERROR TRANSLATION ----------

  EmergencyException _translateException(FirebaseException e) {
    final code = e.code;
    switch (code) {
      case 'permission-denied':
        return const EmergencyException(
          'You do not have permission to make this emergency request. '
              'Please sign in again.',
          code: 'permission-denied',
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return const EmergencyException(
          'Emergency service is unreachable. '
              'Please call your clinic directly right now.',
          code: 'service-unavailable',
        );
      case 'not-found':
        return const EmergencyException(
          'This emergency request could not be found.',
          code: 'not-found',
        );
      case 'cancelled':
        return const EmergencyException(
          'The request was cancelled.',
          code: 'cancelled',
        );
      case 'network-request-failed':
        return const EmergencyException(
          'No internet connection. '
              'Please call your clinic directly right now.',
          code: 'network-error',
        );
      default:
        return EmergencyException(
          e.message ??
              'Something went wrong. Please call your clinic directly.',
          code: code,
        );
    }
  }
}