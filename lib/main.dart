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
import 'features/community/domain/usecases/create_post.dart';
import 'features/community/domain/usecases/create_reply.dart';
import 'features/community/domain/usecases/get_available_groups.dart';
import 'features/community/domain/usecases/get_group_posts.dart';
import 'features/community/presentation/bloc/community_bloc.dart';
import 'features/emergency/domain/repositories/emergency_repository.dart';
import 'features/emergency/domain/usecases/cancel_emergency.dart';
import 'features/emergency/domain/usecases/request_emergency.dart';
import 'features/emergency/presentation/bloc/emergency_bloc.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await configureDependencies();
  runApp(SafeMomApp(authRepository: AuthLocator.buildRepository()));
}

class SafeMomApp extends StatelessWidget {
  const SafeMomApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthLocator.buildBloc(authRepository),
        ),
        BlocProvider<CommunityBloc>(
          create: (_) => CommunityBloc(
            getAvailableGroups: getIt<GetAvailableGroups>(),
            getGroupPosts: getIt<GetGroupPosts>(),
            createPost: getIt<CreatePost>(),
            createReply: getIt<CreateReply>(),
          ),
        ),
        BlocProvider<EmergencyBloc>(
          create: (_) => EmergencyBloc(
            requestEmergency: getIt<RequestEmergency>(),
            cancelEmergency: getIt<CancelEmergency>(),
            repository: getIt<EmergencyRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SafeMom',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}