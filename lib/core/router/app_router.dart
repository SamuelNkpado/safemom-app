import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_confirmation_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/sign_up_wizard_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/community/domain/entities/post.dart';
import '../../features/community/presentation/pages/community_feed_page.dart';
import '../../features/community/presentation/pages/create_post_page.dart';
import '../../features/community/presentation/pages/post_detail_page.dart';
import '../../features/emergency/presentation/pages/emergency_dispatch_page.dart';
import '../../features/symptoms/presentation/pages/danger_check_page.dart';
import '../../features/symptoms/presentation/pages/symptom_page.dart';
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
    // Auth + onboarding wizard (owner: Kyle)
      case AppRoutes.welcome:
        return _page(const WelcomePage(), settings);
      case AppRoutes.login:
        return _page(const LoginPage(), settings);
      case AppRoutes.signup:
        return _page(const SignUpWizardPage(), settings);
      case AppRoutes.resetPassword:
        return _page(const ResetPasswordPage(), settings);
      case AppRoutes.resetPasswordConfirmation:
        final email = settings.arguments as String? ?? 'your email';
        return _page(ResetPasswordConfirmationPage(email: email), settings);
      case AppRoutes.symptomLog:
        return _page(const SymptomPage(), settings);
      case AppRoutes.dangerCheck:
        return _page(const DangerCheckPage(), settings);
    // Emergency (owner: Brenda) — EmergencyBloc is provided at the app root
    // (see main.dart MultiBlocProvider), so no BlocProvider wrapper is needed
    // here. The page needs four required args, passed as a route-arguments map.
      case AppRoutes.emergency:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return _page(
            const Scaffold(
              body: Center(
                child: Text('Emergency dispatch is missing its details.'),
              ),
            ),
            settings,
          );
        }
        return _page(
          EmergencyDispatchPage(
            userId: args['userId'] as String,
            clinicId: args['clinicId'] as String,
            latitude: args['latitude'] as double,
            longitude: args['longitude'] as double,
          ),
          settings,
        );
    // Community (owner: Brenda)
      case AppRoutes.communityFeed:
        return _page(const CommunityFeedPage(), settings);
      case AppRoutes.createPost:
        return _page(const CreatePostPage(), settings);
      case AppRoutes.communityPost:
        final post = settings.arguments as Post;
        return _page(PostDetailPage(post: post), settings);
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