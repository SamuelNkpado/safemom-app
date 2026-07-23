import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/sign_up_wizard_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../navigation/main_nav_shell.dart';
import 'app_routes.dart';
import '../../features/symptoms/presentation/pages/symptom_page.dart';
/// Central route table. Add feature routes here as screens are built, so
/// navigation stays in one place instead of scattered across widgets.
///
/// Usage: Navigator.pushNamed(context, AppRoutes.login);
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.root:
        return _page(const MainNavShell(), settings);

      // Auth + onboarding wizard (owner: Kyle)
      case AppRoutes.welcome:
        return _page(const WelcomePage(), settings);
      case AppRoutes.login:
        return _page(const LoginPage(), settings);
      case AppRoutes.signup:
        return _page(const SignUpWizardPage(), settings);
      case AppRoutes.resetPassword:
        return _page(const ResetPasswordPage(), settings);
      case AppRoutes.symptomLog:
        return _page(const SymptomPage(), settings);

      default:
        return _page(
          Scaffold(
            body: Center(child: Text('No route for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }
}
