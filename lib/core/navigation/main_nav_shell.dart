import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/community/presentation/pages/community_feed_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/symptoms/presentation/pages/symptom_page.dart';
import '../router/app_routes.dart';
import '../widgets/safemom_bottom_nav.dart';

/// Bottom-nav host for the four main tabs, using the shared SafeMomBottomNav
/// (raised SOS button in the centre). Screens live in their own feature
/// folders and are wired here.
///
/// Also acts as the global sign-out listener — if the AuthBloc emits
/// `unauthenticated` while the user is on any tab, we navigate them
/// back to the welcome screen.
class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  int _currentIndex = 0;

  // Demo-safe emergency inputs. The User entity carries no lat/lng, so
  // coordinates are a fixed Kigali location for the demo. clinicId prefers
  // the user's real selectedClinicId and only falls back to this if null.
  static const double _demoLatitude = -1.9441;
  static const double _demoLongitude = 30.0619;
  static const String _demoClinicId = 'demo-clinic-kigali';

  static const List<Widget> _tabs = <Widget>[
    HomePage(),
    SymptomPage(),
    CommunityFeedPage(),
    ProfilePage(),
  ];

  void _onSosPressed() {
    // Shell only renders when authenticated, but guard anyway so a null user
    // never reaches the required-args route.
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.emergency,
      arguments: <String, dynamic>{
        'userId': user.userId,
        'clinicId': user.selectedClinicId ?? _demoClinicId,
        'latitude': _demoLatitude,
        'longitude': _demoLongitude,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
      previous.status != current.status &&
          current.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          AppRoutes.welcome,
              (route) => false,
        );
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: SafeMomBottomNav(
          currentIndex: _currentIndex,
          onTabSelected: (index) => setState(() => _currentIndex = index),
          onSosPressed: _onSosPressed,
        ),
      ),
    );
  }
}