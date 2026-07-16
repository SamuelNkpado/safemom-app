import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Manual dependency injection for the auth feature.
///
/// Wires the real Firebase-backed AuthRepositoryImpl to the AuthBloc.
/// This replaces the earlier FakeAuthRepository that was used to unblock
/// UI development before the backend data layer was built.
///
/// The full backend DI (all 7 features) is handled separately by
/// `configureDependencies()` in `injection_container.dart`. This file
/// exists solely to construct the AuthBloc that lives at the widget-tree
/// root via BlocProvider in main.dart.
class AuthLocator {
  AuthLocator._();

  /// Build the real Firebase-backed auth repository.
  static AuthRepository buildRepository() {
    final datasource = FirebaseAuthDatasource(
      firebaseAuth: fb.FirebaseAuth.instance,
      googleSignIn: GoogleSignIn.instance,
      firestore: FirebaseFirestore.instance,
    );
    return AuthRepositoryImpl(datasource);
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