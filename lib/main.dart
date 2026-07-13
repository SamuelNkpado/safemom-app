import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SafeMomApp());
}

class SafeMomApp extends StatelessWidget {
  const SafeMomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeMom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // TODO(auth): switch initialRoute to AppRoutes.login once auth is wired,
      // and gate MainNavShell behind an authenticated state.
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
