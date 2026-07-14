import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/emergency_request.dart';
import '../models/emergency_request_model.dart';

/// Low-level data source that wraps the emergency_requests Firestore
/// collection.
///
/// Handles all Firestore reads, writes, and real-time streams for
/// emergency requests. This is the only emergency-related class that
/// imports Firebase.
class EmergencyFirestoreDatasource {
  final FirebaseFirestore _firestore;

  EmergencyFirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to the emergency_requests collection.
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('emergency_requests');

  // ---------- CREATE ----------

  /// Create a new emergency request document in Firestore.
  ///
  /// Firestore generates the document ID; the returned model has that ID
  /// populated. status is always 'pending' at creation.
  Future<EmergencyRequestModel> createRequest({
    required String userId,
    required String clinicId,
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();

    final data = {
      'user_id': userId,
      'clinic_id': clinicId,
      'status': 'pending',
      'request_latitude': latitude,
      'request_longitude': longitude,
      'eta_minutes': null,
      'driver_name': null,
      'driver_phone': null,
      'vehicle_plate': null,
      'partner_notified_at': null,
      'created_at': Timestamp.fromDate(now),
      'resolved_at': null,
    };

    final docRef = await _collection.add(data);

    return EmergencyRequestModel(
      requestId: docRef.id,
      userId: userId,
      clinicId: clinicId,
      status: EmergencyStatus.pending,
      requestLatitude: latitude,
      requestLongitude: longitude,
      etaMinutes: null,
      driverName: null,
      driverPhone: null,
      vehiclePlate: null,
      partnerNotifiedAt: null,
      createdAt: now,
      resolvedAt: null,
    );
  }

  // ---------- READ ----------

  /// Fetch a single request by ID.
  Future<EmergencyRequestModel?> getRequest(String requestId) async {
    final doc = await _collection.doc(requestId).get();
    if (!doc.exists) return null;
    return EmergencyRequestModel.fromFirestore(doc);
  }

  /// Fetch all requests for a user, most recent first.
  Future<List<EmergencyRequestModel>> getUserRequests(String userId) async {
    final snapshot = await _collection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => EmergencyRequestModel.fromFirestore(doc))
        .toList();
  }

  /// Fetch the user's currently active request, if any.
  ///
  /// Active = status is pending, dispatched, or en_route.
  Future<EmergencyRequestModel?> getActiveRequest(String userId) async {
    final snapshot = await _collection
        .where('user_id', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'dispatched', 'en_route'])
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return EmergencyRequestModel.fromFirestore(snapshot.docs.first);
  }

  /// Real-time stream of a single emergency request.
  ///
  /// Used by the emergency dispatch screen to show live status updates.
  Stream<EmergencyRequestModel> watchRequest(String requestId) {
    return _collection.doc(requestId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Emergency request $requestId no longer exists.');
      }
      return EmergencyRequestModel.fromFirestore(doc);
    });
  }

  // ---------- UPDATE ----------

  /// Cancel an active request.
  Future<void> cancelRequest(String requestId) async {
    await _collection.doc(requestId).update({
      'status': 'cancelled',
      'resolved_at': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Update the status of a request. In production this would be driven
  /// by a webhook from the dispatch provider; for the prototype the app
  /// updates status directly.
  Future<void> updateStatus({
    required String requestId,
    required EmergencyStatus newStatus,
    int? etaMinutes,
    String? driverName,
    String? driverPhone,
    String? vehiclePlate,
  }) async {
    final updates = <String, dynamic>{
      'status': _statusToString(newStatus),
    };

    if (etaMinutes != null) updates['eta_minutes'] = etaMinutes;
    if (driverName != null) updates['driver_name'] = driverName;
    if (driverPhone != null) updates['driver_phone'] = driverPhone;
    if (vehiclePlate != null) updates['vehicle_plate'] = vehiclePlate;

    // If status is terminal, record the resolution time.
    if (newStatus == EmergencyStatus.arrived ||
        newStatus == EmergencyStatus.cancelled ||
        newStatus == EmergencyStatus.failed) {
      updates['resolved_at'] = Timestamp.fromDate(DateTime.now());
    }

    await _collection.doc(requestId).update(updates);
  }

  /// Record that the user's partner has been notified.
  Future<void> markPartnerNotified(String requestId) async {
    await _collection.doc(requestId).update({
      'partner_notified_at': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ---------- HELPERS ----------

  static String _statusToString(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.pending:
        return 'pending';
      case EmergencyStatus.dispatched:
        return 'dispatched';
      case EmergencyStatus.enRoute:
        return 'en_route';
      case EmergencyStatus.arrived:
        return 'arrived';
      case EmergencyStatus.cancelled:
        return 'cancelled';
      case EmergencyStatus.failed:
        return 'failed';
    }
  }
}