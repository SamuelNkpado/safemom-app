/// Central list of named routes. Reference these constants instead of raw
/// strings when calling Navigator.pushNamed, so typos surface at compile time.
class AppRoutes {
  AppRoutes._();

  // Shell / tabs
  static const String root = '/'; // MainNavShell (bottom nav host)

  // Auth + onboarding wizard (owner: Kyle)
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup'; // 4-step sign-up wizard
  static const String resetPassword = '/reset-password';

  // Emergency (owner: Brenda)
  static const String emergency = '/emergency';

  // Feature detail routes (owner: partner)
  static const String symptomLog = '/symptoms/log';
  static const String communityPost = '/community/post';
  static const String createPost = '/community/create';
  static const String appointments = '/profile/appointments';
  static const String communityFeed = '/community';
}
