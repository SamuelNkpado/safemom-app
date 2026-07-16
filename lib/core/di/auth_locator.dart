import '../../features/auth/data/repositories/fake_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Minimal manual dependency injection for the auth feature.
///
/// One place builds the repository, its use cases, and the bloc. When the
/// backend delivers the real Firebase repository, swap the single line marked
/// below and nothing else changes.
class AuthLocator {
  AuthLocator._();

  static AuthRepository buildRepository() {
    // TODO(backend): return FirebaseAuthRepository() once the data layer lands.
    return FakeAuthRepository();
  }

  static AuthBloc buildBloc(AuthRepository repository) {
    return AuthBloc(
      authRepository: repository,
      signInWithEmail: SignInWithEmail(repository),
      signUpWithEmail: SignUpWithEmail(repository),
      signInWithGoogle: SignInWithGoogle(repository),
      resetPassword: ResetPassword(repository),
      signOut: SignOut(repository),
    );
  }
}
