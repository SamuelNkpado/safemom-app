import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/emergency_request.dart';

/// Data model for the EmergencyRequest entity.
///
/// Extends the pure entity with Firestore serialisation logic.
/// This is the only EmergencyRequest-related class that knows about
/// Firestore — the domain layer stays free of Firebase dependencies.
class EmergencyRequestModel extends EmergencyRequest {
  const EmergencyRequestModel({
    required super.requestId,
    required super.userId,
    required super.clinicId,
    required super.status,
    required super.requestLatitude,
    required super.requestLongitude,
    super.etaMinutes,
    super.driverName,
    super.driverPhone,
    super.vehiclePlate,
    super.partnerNotifiedAt,
    required super.createdAt,
    super.resolvedAt,
  });

  /// Build a model from a Firestore document snapshot.
  factory EmergencyRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return EmergencyRequestModel(
      requestId: doc.id,
      userId: data['user_id'] as String? ?? '',
      clinicId: data['clinic_id'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      requestLatitude: (data['request_latitude'] as num?)?.toDouble() ?? 0.0,
      requestLongitude: (data['request_longitude'] as num?)?.toDouble() ?? 0.0,
      etaMinutes: (data['eta_minutes'] as num?)?.toInt(),
      driverName: data['driver_name'] as String?,
      driverPhone: data['driver_phone'] as String?,
      vehiclePlate: data['vehicle_plate'] as String?,
      partnerNotifiedAt: _timestampToDateTime(data['partner_notified_at']),
      createdAt: _timestampToDateTime(data['created_at']) ?? DateTime.now(),
      resolvedAt: _timestampToDateTime(data['resolved_at']),
    );
  }

  /// Convert this model to a Firestore-writable map.
  ///
  /// Field names match the ERD exactly (snake_case).
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'clinic_id': clinicId,
      'status': _statusToString(status),
      'request_latitude': requestLatitude,
      'request_longitude': requestLongitude,
      'eta_minutes': etaMinutes,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'vehicle_plate': vehiclePlate,
      'partner_notified_at':
      partnerNotifiedAt != null ? Timestamp.fromDate(partnerNotifiedAt!) : null,
      'created_at': Timestamp.fromDate(createdAt),
      'resolved_at': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  /// Convert a pure EmergencyRequest entity to a model.
  factory EmergencyRequestModel.fromEntity(EmergencyRequest request) {
    return EmergencyRequestModel(
      requestId: request.requestId,
      userId: request.userId,
      clinicId: request.clinicId,
      status: request.status,
      requestLatitude: request.requestLatitude,
      requestLongitude: request.requestLongitude,
      etaMinutes: request.etaMinutes,
      driverName: request.driverName,
      driverPhone: request.driverPhone,
      vehiclePlate: request.vehiclePlate,
      partnerNotifiedAt: request.partnerNotifiedAt,
      createdAt: request.createdAt,
      resolvedAt: request.resolvedAt,
    );
  }

  // ---------- ENUM SERIALISATION ----------

  static EmergencyStatus _statusFromString(String? value) {
    switch (value) {
      case 'pending':
        return EmergencyStatus.pending;
      case 'dispatched':
        return EmergencyStatus.dispatched;
      case 'en_route':
        return EmergencyStatus.enRoute;
      case 'arrived':
        return EmergencyStatus.arrived;
      case 'cancelled':
        return EmergencyStatus.cancelled;
      case 'failed':
        return EmergencyStatus.failed;
      default:
        return EmergencyStatus.pending;
    }
  }

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