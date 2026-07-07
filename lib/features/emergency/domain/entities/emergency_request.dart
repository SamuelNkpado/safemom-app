/// Represents an emergency dispatch request initiated by a user.
///
/// The highest-stakes entity in the SafeMom app.
/// Pure Dart entity — no Firebase, no Flutter dependencies.
/// Fields match the `emergency_requests` collection in the ERD.
class EmergencyRequest {
  final String requestId;
  final String userId;
  final String clinicId;
  final EmergencyStatus status;
  final double requestLatitude;
  final double requestLongitude;
  final int? etaMinutes;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;
  final DateTime? partnerNotifiedAt;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const EmergencyRequest({
    required this.requestId,
    required this.userId,
    required this.clinicId,
    required this.status,
    required this.requestLatitude,
    required this.requestLongitude,
    this.etaMinutes,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    this.partnerNotifiedAt,
    required this.createdAt,
    this.resolvedAt,
  });

  /// True if this request is currently in progress (not yet resolved or cancelled).
  bool get isActive =>
      status == EmergencyStatus.pending ||
          status == EmergencyStatus.dispatched ||
          status == EmergencyStatus.enRoute;

  EmergencyRequest copyWith({
    String? requestId,
    String? userId,
    String? clinicId,
    EmergencyStatus? status,
    double? requestLatitude,
    double? requestLongitude,
    int? etaMinutes,
    String? driverName,
    String? driverPhone,
    String? vehiclePlate,
    DateTime? partnerNotifiedAt,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return EmergencyRequest(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      clinicId: clinicId ?? this.clinicId,
      status: status ?? this.status,
      requestLatitude: requestLatitude ?? this.requestLatitude,
      requestLongitude: requestLongitude ?? this.requestLongitude,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      partnerNotifiedAt: partnerNotifiedAt ?? this.partnerNotifiedAt,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

/// Lifecycle states of an emergency request.
enum EmergencyStatus {
  pending,       // Request created, awaiting provider dispatch
  dispatched,    // Provider has assigned a driver
  enRoute,       // Driver is on the way
  arrived,       // Driver has arrived / user reached facility
  cancelled,     // User cancelled the request
  failed,        // No provider available; user directed to fallback
}