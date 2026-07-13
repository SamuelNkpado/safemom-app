/// Central list of named routes. Reference these constants instead of raw
/// strings when calling Navigator.pushNamed, so typos surface at compile time.
class AppRoutes {
  AppRoutes._();

  // Shell / tabs
  static const String root = '/'; // MainNavShell (bottom nav host)

  // Auth (owner: Kyle)
  static const String login = '/login';
  static const String signup = '/signup';
  static const String resetPassword = '/reset-password';

  // Onboarding (owner: Kyle)
  static const String onboarding = '/onboarding';

  // Emergency (owner: Kyle)
  static const String emergency = '/emergency';

  // Feature detail routes (owner: partner)
  static const String symptomLog = '/symptoms/log';
  static const String communityPost = '/community/post';
  static const String createPost = '/community/create';
  static const String appointments = '/profile/appointments';
}
