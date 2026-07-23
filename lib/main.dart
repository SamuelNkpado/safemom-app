import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/auth_locator.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/domain/entities/user_preferences.dart' as prefs_entity;
import 'features/profile/domain/repositories/preferences_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  runApp(SafeMomApp(authRepository: AuthLocator.buildRepository()));
}

class SafeMomApp extends StatelessWidget {
  const SafeMomApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    final preferencesRepo = getIt<PreferencesRepository>();

    return BlocProvider<AuthBloc>(
      create: (_) => AuthLocator.buildBloc(authRepository),
      child: StreamBuilder<prefs_entity.UserPreferences>(
        stream: preferencesRepo.watchPreferences(),
        builder: (context, snapshot) {
          final prefs = snapshot.data ?? prefs_entity.UserPreferences.defaults();
          final themeMode = _toFlutterThemeMode(prefs.themeMode);

          return MaterialApp(
            title: 'SafeMom',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            initialRoute: AppRoutes.welcome,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }

  /// Convert our domain [prefs_entity.ThemeMode] to Flutter's [ThemeMode].
  ThemeMode _toFlutterThemeMode(prefs_entity.ThemeMode mode) {
    switch (mode) {
      case prefs_entity.ThemeMode.light:
        return ThemeMode.light;
      case prefs_entity.ThemeMode.dark:
        return ThemeMode.dark;
      case prefs_entity.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}