import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/sign_up_wizard_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/community/domain/entities/post.dart';
import '../../features/community/presentation/pages/community_feed_page.dart';
import '../../features/community/presentation/pages/create_post_page.dart';
import '../../features/community/presentation/pages/post_detail_page.dart';
import '../navigation/main_nav_shell.dart';
import 'app_routes.dart';

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