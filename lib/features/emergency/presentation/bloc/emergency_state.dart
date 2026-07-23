import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_request.dart';

enum SosStatus { idle, sending, active, cancelling, cancelled, error }

class EmergencyState extends Equatable {
  final SosStatus sosStatus;
  final EmergencyRequest? request;
  final String? sosError;

  const EmergencyState({
    this.sosStatus = SosStatus.idle,
    this.request,
    this.sosError,
  });

  EmergencyState copyWith({
    SosStatus? sosStatus,
    EmergencyRequest? request,
    String? sosError,
  }) {
    return EmergencyState(
      sosStatus: sosStatus ?? this.sosStatus,
      request: request ?? this.request,
      sosError: sosError,
    );
  }

  @override
  List<Object?> get props => [sosStatus, request, sosError];
}
