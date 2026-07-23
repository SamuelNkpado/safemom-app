import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/emergency_request.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../domain/usecases/cancel_emergency.dart';
import '../../domain/usecases/request_emergency.dart';
import 'emergency_event.dart';
import 'emergency_state.dart';

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final RequestEmergency requestEmergency;
  final CancelEmergency cancelEmergency;
  final EmergencyRepository repository;

  StreamSubscription<EmergencyRequest>? _requestSub;

  EmergencyBloc({
    required this.requestEmergency,
    required this.cancelEmergency,
    required this.repository,
  }) : super(const EmergencyState()) {
    on<SosTriggered>(_onSosTriggered);
    on<DispatchCancelRequested>(_onDispatchCancelRequested);
    // Handles updates from the live watchRequest() stream — routed through
    // add() rather than emitted directly from the stream listener, since
    // that listener can fire after the handler that created it has already
    // completed, which bloc disallows (and will throw in debug builds).
    on<_RequestUpdated>((event, emit) =>
        emit(state.copyWith(sosStatus: SosStatus.active, request: event.request)));
  }

  Future<void> _onSosTriggered(SosTriggered event, Emitter<EmergencyState> emit) async {
    emit(state.copyWith(sosStatus: SosStatus.sending, sosError: null));
    try {
      EmergencyRequest request;
      try {
        request = await requestEmergency(
          userId: event.userId,
          clinicId: event.clinicId,
          latitude: event.latitude,
          longitude: event.longitude,
        );
      } on StateError {
        final existing = await repository.getActiveRequest(event.userId);
        if (existing == null) rethrow;
        request = existing;
      }

      if (request.driverName == null) {
        await repository.updateStatus(
          requestId: request.requestId,
          newStatus: EmergencyStatus.dispatched,
          etaMinutes: 8,
          driverName: 'Joseph Kamau',
          driverPhone: '+254711000000',
          vehiclePlate: 'KCA 234X',
        );
        await repository.markPartnerNotified(request.requestId);
      }

      await _requestSub?.cancel();
      _requestSub = repository.watchRequest(request.requestId).listen((updated) {
        add(_RequestUpdated(updated));
      });
    } on ArgumentError catch (e) {
      emit(state.copyWith(sosStatus: SosStatus.error, sosError: e.message.toString()));
    } on EmergencyException catch (e) {
      emit(state.copyWith(sosStatus: SosStatus.error, sosError: e.message));
    } catch (_) {
      emit(state.copyWith(
        sosStatus: SosStatus.error,
        sosError: 'SOS could not be sent. Call your clinic directly.',
      ));
    }
  }

  Future<void> _onDispatchCancelRequested(DispatchCancelRequested event, Emitter<EmergencyState> emit) async {
    final requestId = state.request?.requestId;
    if (requestId == null) return;
    emit(state.copyWith(sosStatus: SosStatus.cancelling));
    try {
      await cancelEmergency(requestId: requestId, userId: event.userId);
      await _requestSub?.cancel();
      emit(state.copyWith(sosStatus: SosStatus.cancelled));
    } on StateError catch (e) {
      emit(state.copyWith(sosStatus: SosStatus.error, sosError: e.message));
    } catch (_) {
      emit(state.copyWith(
        sosStatus: SosStatus.error,
        sosError: 'Could not cancel — call your clinic directly if help is no longer needed.',
      ));
    }
  }

  @override
  Future<void> close() async {
    await _requestSub?.cancel();
    return super.close();
  }
}

class _RequestUpdated extends EmergencyEvent {
  final EmergencyRequest request;
  const _RequestUpdated(this.request);
  @override
  List<Object?> get props => [request];
}
