import 'package:ev_protocol/ev_protocol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/features/auth/presentation/pages/at_login_page.dart';
import 'package:sailor/features/auth/presentation/pages/backup_key_page.dart';
import 'package:sailor/features/auth/presentation/pages/create_identity_page.dart';
import 'package:sailor/features/auth/presentation/pages/welcome_page.dart';
import 'package:sailor/features/auth/presentation/providers/auth_providers.dart';
import 'package:sailor/features/events/presentation/pages/create_event_page.dart';
import 'package:sailor/features/events/presentation/pages/event_detail_page.dart';
import 'package:sailor/features/profile/presentation/pages/profile_page.dart';
import 'package:sailor/features/shell/presentation/pages/main_shell.dart';

/// App routes.
abstract final class AppRoutes {
  static const String welcome = '/welcome';
  static const String createIdentity = '/create-identity';
  static const String backupKey = '/backup-key';
  static const String atLogin = '/at-login';
  static const String home = '/';
  static const String eventDetail = '/event';
  static const String createEvent = '/create-event';
  static const String profile = '/profile';
}

/// GoRouter configuration with auth redirect.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.welcome ||
          state.matchedLocation == AppRoutes.createIdentity ||
          state.matchedLocation == AppRoutes.backupKey ||
          state.matchedLocation == AppRoutes.atLogin;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.welcome;
      }
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.atLogin,
        builder: (context, state) => const AtLoginPage(),
      ),
      GoRoute(
        path: AppRoutes.createIdentity,
        builder: (context, state) => const CreateIdentityPage(),
      ),
      GoRoute(
        path: AppRoutes.backupKey,
        builder: (context, state) {
          final backupKey = state.extra as String? ?? '';
          return BackupKeyPage(backupKey: backupKey);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '${AppRoutes.eventDetail}/:id',
        builder: (context, state) {
          final event = state.extra as EvEvent?;
          if (event == null) {
            return const MainShell();
          }
          return EventDetailPage(event: event);
        },
      ),
      GoRoute(
        path: AppRoutes.createEvent,
        builder: (context, state) => const CreateEventPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
