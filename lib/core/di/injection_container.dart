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
// Emergency
import '../../features/emergency/data/datasources/emergency_firestore_datasource.dart';
import '../../features/emergency/data/repositories/emergency_repository_impl.dart';
import '../../features/emergency/domain/repositories/emergency_repository.dart';
import '../../features/emergency/domain/usecases/cancel_emergency.dart';
import '../../features/emergency/domain/usecases/request_emergency.dart';
// Symptoms
import '../../features/symptoms/data/datasources/symptom_firestore_datasource.dart';
import '../../features/symptoms/data/repositories/symptom_repository_impl.dart';
import '../../features/symptoms/domain/repositories/symptom_repository.dart';
import '../../features/symptoms/domain/usecases/log_symptom.dart';
import '../../features/symptoms/domain/usecases/run_danger_check.dart';

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



// ---------- EMERGENCY FEATURE ----------

  // Datasource
  getIt.registerLazySingleton<EmergencyFirestoreDatasource>(
        () => EmergencyFirestoreDatasource(firestore: getIt<FirebaseFirestore>()),
  );

  // Repository
  getIt.registerLazySingleton<EmergencyRepository>(
        () => EmergencyRepositoryImpl(getIt<EmergencyFirestoreDatasource>()),
  );

  // Use cases
  getIt.registerFactory<RequestEmergency>(
        () => RequestEmergency(getIt<EmergencyRepository>()),
  );
  getIt.registerFactory<CancelEmergency>(
        () => CancelEmergency(getIt<EmergencyRepository>()),
  );

  // ---------- SYMPTOMS FEATURE ----------

  // Datasource
  getIt.registerLazySingleton<SymptomFirestoreDatasource>(
        () => SymptomFirestoreDatasource(firestore: getIt<FirebaseFirestore>()),
  );

  // Repository
  getIt.registerLazySingleton<SymptomRepository>(
        () => SymptomRepositoryImpl(getIt<SymptomFirestoreDatasource>()),
  );

  // Use cases
  getIt.registerFactory<LogSymptom>(
        () => LogSymptom(getIt<SymptomRepository>()),
  );
  getIt.registerFactory<RunDangerCheck>(
        () => RunDangerCheck(getIt<SymptomRepository>()),
  );

  // ---------- FUTURE FEATURES ----------
  // Community, Preferences, WeeklyTips, Appointments
  // will be registered here as their data layers are built.
}

Future<void> resetDependencies() async {
  await getIt.reset();
}