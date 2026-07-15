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
// Preferences
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/profile/data/repositories/preferences_repository_impl.dart';
import '../../features/profile/domain/repositories/preferences_repository.dart';
import '../../features/profile/domain/usecases/get_preferences.dart';
import '../../features/profile/domain/usecases/mark_onboarding_complete.dart';
import '../../features/profile/domain/usecases/update_language.dart';
import '../../features/profile/domain/usecases/update_theme.dart';
// Community
import '../../features/community/data/datasources/community_firestore_datasource.dart';
import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/domain/usecases/create_post.dart';
import '../../features/community/domain/usecases/create_reply.dart';
import '../../features/community/domain/usecases/get_available_groups.dart';
import '../../features/community/domain/usecases/get_group_posts.dart';
import '../../features/community/domain/usecases/join_group.dart';
import '../../features/community/domain/usecases/leave_group.dart';
// Weekly Tips
import '../../features/home/data/datasources/weekly_tip_firestore_datasource.dart';
import '../../features/home/data/repositories/weekly_tip_repository_impl.dart';
import '../../features/home/domain/repositories/weekly_tip_repository.dart';
import '../../features/home/domain/usecases/get_saved_tips.dart';
import '../../features/home/domain/usecases/get_weekly_tip_for_week.dart';
import '../../features/home/domain/usecases/save_tip.dart';
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
  // SharedPreferences (async — must be resolved before use)
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

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

  // ---------- PREFERENCES FEATURE ----------

  // Repository (no separate datasource — SharedPreferences is simple enough
  // to talk to directly from the repository implementation)
  getIt.registerLazySingleton<PreferencesRepository>(
        () => PreferencesRepositoryImpl(getIt<SharedPreferences>()),
  );

  // Use cases
  getIt.registerFactory<GetPreferences>(
        () => GetPreferences(getIt<PreferencesRepository>()),
  );
  getIt.registerFactory<UpdateLanguage>(
        () => UpdateLanguage(getIt<PreferencesRepository>()),
  );
  getIt.registerFactory<UpdateTheme>(
        () => UpdateTheme(getIt<PreferencesRepository>()),
  );
  getIt.registerFactory<MarkOnboardingComplete>(
        () => MarkOnboardingComplete(getIt<PreferencesRepository>()),
  );

// ---------- COMMUNITY FEATURE ----------

  // Datasource
  getIt.registerLazySingleton<CommunityFirestoreDatasource>(
        () => CommunityFirestoreDatasource(firestore: getIt<FirebaseFirestore>()),
  );

  // Repository
  getIt.registerLazySingleton<CommunityRepository>(
        () => CommunityRepositoryImpl(getIt<CommunityFirestoreDatasource>()),
  );

  // Use cases
  getIt.registerFactory<JoinGroup>(
        () => JoinGroup(getIt<CommunityRepository>()),
  );
  getIt.registerFactory<LeaveGroup>(
        () => LeaveGroup(getIt<CommunityRepository>()),
  );
  getIt.registerFactory<GetAvailableGroups>(
        () => GetAvailableGroups(getIt<CommunityRepository>()),
  );
  getIt.registerFactory<CreatePost>(
        () => CreatePost(getIt<CommunityRepository>()),
  );
  getIt.registerFactory<GetGroupPosts>(
        () => GetGroupPosts(getIt<CommunityRepository>()),
  );
  getIt.registerFactory<CreateReply>(
        () => CreateReply(getIt<CommunityRepository>()),
  );

// ---------- WEEKLY TIPS FEATURE ----------

  // Datasource
  getIt.registerLazySingleton<WeeklyTipFirestoreDatasource>(
        () => WeeklyTipFirestoreDatasource(firestore: getIt<FirebaseFirestore>()),
  );

  // Repository
  getIt.registerLazySingleton<WeeklyTipRepository>(
        () => WeeklyTipRepositoryImpl(getIt<WeeklyTipFirestoreDatasource>()),
  );

  // Use cases
  getIt.registerFactory<GetWeeklyTipForWeek>(
        () => GetWeeklyTipForWeek(getIt<WeeklyTipRepository>()),
  );
  getIt.registerFactory<SaveTip>(
        () => SaveTip(getIt<WeeklyTipRepository>()),
  );
  getIt.registerFactory<GetSavedTips>(
        () => GetSavedTips(getIt<WeeklyTipRepository>()),
  );

  // ---------- FUTURE FEATURES ----------
  // Appointments will be registered here.
}


Future<void> resetDependencies() async {
  await getIt.reset();
}