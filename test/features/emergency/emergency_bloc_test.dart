import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safemom/features/emergency/domain/entities/emergency_request.dart';
import 'package:safemom/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:safemom/features/emergency/domain/usecases/cancel_emergency.dart';
import 'package:safemom/features/emergency/domain/usecases/request_emergency.dart';
import 'package:safemom/features/emergency/presentation/bloc/emergency_bloc.dart';
import 'package:safemom/features/emergency/presentation/bloc/emergency_event.dart';
import 'package:safemom/features/emergency/presentation/bloc/emergency_state.dart';

class MockEmergencyRepository extends Mock implements EmergencyRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(EmergencyStatus.pending);
  });

  late MockEmergencyRepository repository;
  late EmergencyBloc bloc;

  final pendingRequest = EmergencyRequest(
    requestId: 'r1',
    userId: 'u1',
    clinicId: 'c1',
    status: EmergencyStatus.pending,
    requestLatitude: -1.29,
    requestLongitude: 36.82,
    createdAt: DateTime(2026, 1, 1),
  );

  final dispatchedRequest = pendingRequest.copyWith(
    status: EmergencyStatus.dispatched,
    etaMinutes: 8,
    driverName: 'Joseph Kamau',
    driverPhone: '+254711000000',
    vehiclePlate: 'KCA 234X',
    partnerNotifiedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = MockEmergencyRepository();
    bloc = EmergencyBloc(
      requestEmergency: RequestEmergency(repository),
      cancelEmergency: CancelEmergency(repository),
      repository: repository,
    );
  });

  tearDown(() => bloc.close());

  blocTest<EmergencyBloc, EmergencyState>(
    'SosTriggered creates a request, simulates dispatch, and starts watching it',
    build: () {
      when(() => repository.getActiveRequest(any())).thenAnswer((_) async => null);
      when(() => repository.createRequest(
            userId: any(named: 'userId'),
            clinicId: any(named: 'clinicId'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          )).thenAnswer((_) async => pendingRequest);
      when(() => repository.updateStatus(
            requestId: any(named: 'requestId'),
            newStatus: any(named: 'newStatus'),
            etaMinutes: any(named: 'etaMinutes'),
            driverName: any(named: 'driverName'),
            driverPhone: any(named: 'driverPhone'),
            vehiclePlate: any(named: 'vehiclePlate'),
          )).thenAnswer((_) async {});
      when(() => repository.markPartnerNotified(any())).thenAnswer((_) async {});
      when(() => repository.watchRequest(any())).thenAnswer((_) => Stream.value(dispatchedRequest));
      return bloc;
    },
    act: (bloc) => bloc.add(const SosTriggered(
      userId: 'u1',
      clinicId: 'c1',
      latitude: -1.29,
      longitude: 36.82,
    )),
    expect: () => [
      predicate<EmergencyState>((s) => s.sosStatus == SosStatus.sending),
      predicate<EmergencyState>((s) =>
          s.sosStatus == SosStatus.active && s.request?.driverName == 'Joseph Kamau'),
    ],
  );

  blocTest<EmergencyBloc, EmergencyState>(
    'DispatchCancelRequested emits [cancelling, cancelled]',
    build: () {
      when(() => repository.getRequest(any())).thenAnswer((_) async => dispatchedRequest);
      when(() => repository.cancelRequest(any())).thenAnswer((_) async {});
      return bloc;
    },
    seed: () => EmergencyState(sosStatus: SosStatus.active, request: dispatchedRequest),
    act: (bloc) => bloc.add(const DispatchCancelRequested('u1')),
    expect: () => [
      predicate<EmergencyState>((s) => s.sosStatus == SosStatus.cancelling),
      predicate<EmergencyState>((s) => s.sosStatus == SosStatus.cancelled),
    ],
  );
}
