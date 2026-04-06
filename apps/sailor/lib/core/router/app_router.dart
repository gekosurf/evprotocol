import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/features/auth/presentation/pages/backup_key_page.dart';
import 'package:sailor/features/auth/presentation/pages/create_identity_page.dart';
import 'package:sailor/features/auth/presentation/pages/welcome_page.dart';
import 'package:sailor/features/auth/presentation/providers/auth_providers.dart';
import 'package:sailor/features/home/presentation/pages/home_page.dart';

/// App routes.
abstract final class AppRoutes {
  static const String welcome = '/welcome';
  static const String createIdentity = '/create-identity';
  static const String backupKey = '/backup-key';
  static const String home = '/';
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
          state.matchedLocation == AppRoutes.backupKey;

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
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});
