import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/preset_editor/presentation/preset_editor_screen.dart';
import '../../features/video_library/presentation/video_library_screen.dart';
import '../../features/clip_detail/presentation/clip_detail_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../common/widgets/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.read(authStateProvider);
  
  // Create a ValueNotifier to force GoRouter to re-evaluate the redirect logic
  final notifier = ValueNotifier<bool>(authState);
  ref.listen<bool>(authStateProvider, (_, next) {
    notifier.value = next;
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isAuth = notifier.value;
      final isGoingToLogin = state.matchedLocation == '/login';
      
      if (!isAuth && !isGoingToLogin) {
        return '/login';
      }
      
      if (isAuth && isGoingToLogin) {
        // If they've seen onboarding, go to queue, else /
        final prefs = ref.read(sharedPreferencesProvider);
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
        return hasSeenOnboarding ? '/queue' : '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/clips',
            builder: (context, state) => const VideoLibraryScreen(),
          ),
          GoRoute(
            path: '/queue',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/presets',
            builder: (context, state) => const PresetEditorScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/clips/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ClipDetailScreen(clipId: id);
        },
      ),
    ],
  );
});
