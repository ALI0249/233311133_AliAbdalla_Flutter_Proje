import 'package:go_router/go_router.dart';

import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/museums/museum_list_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/staff/staff_dashboard_screen.dart';

/// Role-aware app router.
///
/// - `/splash`   — while AuthState is still loading the profile.
/// - `/login`, `/register` — public.
/// - `/museums`  — visitor home.
/// - `/staff`    — staff home.
/// - `/profile`  — both roles.
///
/// The redirect logic ensures users land on the right home for their role
/// and cannot reach screens they're not allowed to.
GoRouter buildRouter(AuthState auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/museums', builder: (_, _) => const MuseumListScreen()),
      GoRoute(path: '/staff', builder: (_, _) => const StaffDashboardScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loading = auth.loading;
      final signedIn = auth.signedIn;
      final isPersonel = auth.profile?.isPersonel ?? false;

      // While we don't yet know the auth status, hold at splash.
      if (loading) {
        return loc == '/splash' ? null : '/splash';
      }

      final atPublic = loc == '/login' || loc == '/register' || loc == '/splash';

      if (!signedIn) {
        return atPublic && loc != '/splash' ? null : '/login';
      }

      // Signed in. Route to the correct home if currently on a public route.
      if (atPublic) {
        return isPersonel ? '/staff' : '/museums';
      }

      // Block visitor from staff-only pages and vice versa.
      if (loc.startsWith('/staff') && !isPersonel) return '/museums';
      if (loc.startsWith('/museums') && isPersonel) return '/staff';

      return null;
    },
  );
}
