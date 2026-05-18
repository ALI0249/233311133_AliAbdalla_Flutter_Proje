import 'package:go_router/go_router.dart';

import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/museums/museum_detail_screen.dart';
import '../features/museums/museum_list_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/staff/staff_dashboard_screen.dart';
import '../features/tickets/_placeholder_screens.dart';

/// Role-aware app router.
///
/// - `/splash`              — while AuthState is still loading the profile
/// - `/login`, `/register`  — public
/// - `/museums`             — visitor home (museum list)
/// - `/museums/:id`         — museum detail + exhibitions
/// - `/tickets`             — visitor's own ticket list (commit 4)
/// - `/tickets/buy`         — ticket purchase form (commit 4)
/// - `/staff`               — staff home
/// - `/profile`             — both roles
GoRouter buildRouter(AuthState auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/museums', builder: (_, _) => const MuseumListScreen()),
      GoRoute(
        path: '/museums/:id',
        builder: (_, state) =>
            MuseumDetailScreen(museumId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tickets',
        builder: (_, _) =>
            const TicketsPlaceholderScreen(title: 'Biletlerim'),
      ),
      GoRoute(
        path: '/tickets/buy',
        builder: (_, _) =>
            const TicketsPlaceholderScreen(title: 'Bilet Al'),
      ),
      GoRoute(path: '/staff', builder: (_, _) => const StaffDashboardScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loading = auth.loading;
      final signedIn = auth.signedIn;
      final isPersonel = auth.profile?.isPersonel ?? false;

      if (loading) {
        return loc == '/splash' ? null : '/splash';
      }

      final atPublic = loc == '/login' || loc == '/register' || loc == '/splash';

      if (!signedIn) {
        return atPublic && loc != '/splash' ? null : '/login';
      }

      if (atPublic) {
        return isPersonel ? '/staff' : '/museums';
      }

      // Block staff-only and visitor-only sections from the wrong role.
      if (loc.startsWith('/staff') && !isPersonel) return '/museums';
      if ((loc.startsWith('/museums') || loc.startsWith('/tickets')) &&
          isPersonel) {
        return '/staff';
      }

      return null;
    },
  );
}
