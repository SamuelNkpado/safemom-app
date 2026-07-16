import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safemom/features/auth/domain/entities/user.dart';
import 'package:safemom/features/auth/domain/repositories/auth_repository.dart';
import 'package:safemom/features/auth/domain/usecases/reset_password.dart';
import 'package:safemom/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:safemom/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:safemom/features/auth/domain/usecases/sign_out.dart';
import 'package:safemom/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:safemom/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:safemom/features/auth/presentation/bloc/auth_event.dart';
import 'package:safemom/features/auth/presentation/bloc/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSignInWithEmail extends Mock implements SignInWithEmail {}

class _MockSignUpWithEmail extends Mock implements SignUpWithEmail {}

class _MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class _MockResetPassword extends Mock implements ResetPassword {}

class _MockSignOut extends Mock implements SignOut {}

void main() {
  late _MockAuthRepository repository;
  late _MockSignInWithEmail signInWithEmail;
  late _MockSignUpWithEmail signUpWithEmail;
  late _MockSignInWithGoogle signInWithGoogle;
  late _MockResetPassword resetPassword;
  late _MockSignOut signOut;

  final testUser = User(
    userId: 'u1',
    name: 'Amina',
    email: 'amina@example.com',
    phoneNumber: '+254712345678',
    dueDate: DateTime(2026, 9, 1),
    currentWeek: 24,
    language: 'en',
    createdAt: DateTime(2026, 1, 1),
    lastActiveAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = _MockAuthRepository();
    signInWithEmail = _MockSignInWithEmail();
    signUpWithEmail = _MockSignUpWithEmail();
    signInWithGoogle = _MockSignInWithGoogle();
    resetPassword = _MockResetPassword();
    signOut = _MockSignOut();

    // Bloc subscribes to this stream on construction.
    when(() => repository.authStateChanges)
        .thenAnswer((_) => const Stream<User?>.empty());
  });

  AuthBloc buildBloc() => AuthBloc(
        authRepository: repository,
        signInWithEmail: signInWithEmail,
        signUpWithEmail: signUpWithEmail,
        signInWithGoogle: signInWithGoogle,
        resetPassword: resetPassword,
        signOut: signOut,
      );

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits submitting then success when sign-in succeeds',
      build: () {
        when(
          () => signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthSignInRequested(email: 'amina@example.com', password: 'pass1234'),
      ),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.formStatus, 'formStatus', AuthFormStatus.submitting),
        isA<AuthState>()
            .having((s) => s.formStatus, 'formStatus', AuthFormStatus.success),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits failure with a message when validation throws ArgumentError',
      build: () {
        when(
          () => signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(ArgumentError('Please enter a valid email address.'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthSignInRequested(email: 'bad', password: ''),
      ),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.formStatus, 'formStatus', AuthFormStatus.submitting),
        isA<AuthState>()
            .having((s) => s.formStatus, 'formStatus', AuthFormStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('valid email')),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits success with an info message when password reset succeeds',
      build: () {
        when(() => resetPassword(email: any(named: 'email')))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AuthPasswordResetRequested('amina@example.com')),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.formStatus, 'formStatus', AuthFormStatus.submitting),
        isA<AuthState>()
            .having((s) => s.formStatus, 'formStatus', AuthFormStatus.success)
            .having((s) => s.infoMessage, 'infoMessage', isNotNull),
      ],
    );
  });
}
