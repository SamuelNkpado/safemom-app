import 'package:flutter/material.dart';

import '../navigation/main_nav_shell.dart';
import 'app_routes.dart';

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

      // TODO(auth): replace with LoginPage / SignupPage / ResetPasswordPage.
      // TODO(onboarding): add AppRoutes.onboarding.
      // TODO(emergency): add AppRoutes.emergency.
      // TODO(feature owners): register detail routes as screens are built.

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
