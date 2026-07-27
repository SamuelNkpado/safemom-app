import 'package:equatable/equatable.dart';

abstract class EmergencyEvent extends Equatable {
  const EmergencyEvent();
  @override
  List<Object?> get props => [];
}

class SosTriggered extends EmergencyEvent {
  final String userId;
  final String clinicId;
  final double latitude;
  final double longitude;
  const SosTriggered({
    required this.userId,
    required this.clinicId,
    required this.latitude,
    required this.longitude,
  });
  @override
  List<Object?> get props => [userId, clinicId, latitude, longitude];
}

class DispatchCancelRequested extends EmergencyEvent {
  final String userId;
  const DispatchCancelRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}
