import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Auth
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';

/// The global service locator.
///
/// Use this from anywhere to fetch a dependency:
///
///     final signIn = getIt<SignInWithEmail>();
///     final user = await signIn(email: '...', password: '...');
///
/// This means UI code never has to construct a datasource or repository
/// by hand — the DI container handles the wiring.
final GetIt getIt = GetIt.instance;

/// Configure and register every dependency the app needs.
///
/// Call this once at app startup, before runApp:
///
///     Future<void> main() async {
///       WidgetsFlutterBinding.ensureInitialized();
///       await Firebase.initializeApp(...);
///       await configureDependencies();
///       runApp(const MyApp());
///     }
Future<void> configureDependencies() async {
  // ---------- EXTERNAL SERVICES (singletons) ----------
  // These come from the Firebase SDK. We wrap them in DI so we can
  // replace them with fakes in tests.
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  // ---------- AUTH FEATURE ----------

  // Datasource
  getIt.registerLazySingleton<FirebaseAuthDatasource>(
        () => FirebaseAuthDatasource(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(getIt<FirebaseAuthDatasource>()),
  );

  // Use cases
  getIt.registerFactory<SignUpWithEmail>(
        () => SignUpWithEmail(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignInWithEmail>(
        () => SignInWithEmail(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignInWithGoogle>(
        () => SignInWithGoogle(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignOut>(
        () => SignOut(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ResetPassword>(
        () => ResetPassword(getIt<AuthRepository>()),
  );

  // ---------- FUTURE FEATURES ----------
  // As other features get their data-layer implementations built,
  // register their datasources, repositories, and use cases here.
  //
  // Example structure to add later:
  //
  //   // Symptoms
  //   getIt.registerLazySingleton<SymptomFirestoreDatasource>(...);
  //   getIt.registerLazySingleton<SymptomRepository>(...);
  //   getIt.registerFactory<LogSymptom>(...);
  //
  //   // Emergency, Community, Preferences, WeeklyTips, Appointments...
}

/// Reset the container. Only used in tests to guarantee a clean slate
/// between test cases.
Future<void> resetDependencies() async {
  await getIt.reset();
}