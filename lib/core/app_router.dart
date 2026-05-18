import 'package:go_router/go_router.dart';

import '../features/artifacts/artifact_detail_screen.dart';
import '../features/artifacts/artifact_list_screen.dart';
import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/museums/museum_detail_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/staff/_staff_placeholders.dart';
import '../features/staff/staff_dashboard_screen.dart';
import '../features/staff/stats_screen.dart';
import '../features/staff/ticket_scan_screen.dart';
import '../features/tickets/my_tickets_screen.dart';
import '../features/tickets/ticket_purchase_screen.dart';

/// Role-aware app router (single-museum).
///
/// Public:
///  - `/splash`, `/login`, `/register`
///
/// Visitor (ziyaretci):
///  - `/home`           home with occupancy + featured artifacts + Bilet Al
///  - `/museum/:id`     müze hakkında (detail page)
///  - `/artifacts`      browse all artifacts
///  - `/artifacts/:id`  artifact detail with QR
///  - `/tickets`        my tickets (commit 5)
///  - `/tickets/buy`    ticket purchase (commit 5)
///
/// Staff (personel):
///  - `/staff`          staff home/dashboard (commit 7)
///
/// Admin:
///  - `/staff`          (also)
///  - `/admin`          admin panel (commit 8)
///
/// Both roles:
///  - `/profile`
GoRouter buildRouter(AuthState auth) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/museum/:id',
        builder: (_, state) =>
            MuseumDetailScreen(museumId: state.pathParameters['id']!),
      ),
      GoRoute(
          path: '/artifacts',
          builder: (_, _) => const ArtifactListScreen()),
      GoRoute(
        path: '/artifacts/:id',
        builder: (_, state) =>
            ArtifactDetailScreen(artifactId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/tickets', builder: (_, _) => const MyTicketsScreen()),
      GoRoute(
          path: '/tickets/buy',
          builder: (_, _) => const TicketPurchaseScreen()),
      GoRoute(path: '/staff', builder: (_, _) => const StaffDashboardScreen()),
      GoRoute(
          path: '/staff/scan',
          builder: (_, _) => const TicketScanScreen()),
      GoRoute(
          path: '/staff/stats', builder: (_, _) => const StatsScreen()),
      GoRoute(
        path: '/staff/artifacts',
        builder: (_, _) => const StaffPlaceholderScreen(
            title: 'Eser Yönetimi',
            commitNote: 'Eser CRUD ekranı bir sonraki adımda eklenecek.'),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, _) => const StaffPlaceholderScreen(
            title: 'Yönetici Paneli',
            commitNote:
                'Personel yönetimi, gelişmiş istatistikler ve sistem logları bir sonraki adımda eklenecek.'),
      ),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loading = auth.loading;
      final signedIn = auth.signedIn;
      final profile = auth.profile;
      final isStaff = profile?.isPersonel ?? false;
      final isAdmin = profile?.isAdmin ?? false;
      final isStaffOrAdmin = isStaff || isAdmin;

      if (loading) {
        return loc == '/splash' ? null : '/splash';
      }

      final atPublic =
          loc == '/login' || loc == '/register' || loc == '/splash';

      if (!signedIn) {
        return atPublic && loc != '/splash' ? null : '/login';
      }

      // Signed in. Direct from a public route to the correct home.
      if (atPublic) {
        return isStaffOrAdmin ? '/staff' : '/home';
      }

      // Visitor-only sections — block staff/admin from buying tickets etc.
      final visitorOnly = loc.startsWith('/home') ||
          loc.startsWith('/artifacts') ||
          loc.startsWith('/museum') ||
          loc.startsWith('/tickets');
      if (visitorOnly && isStaffOrAdmin) return '/staff';

      // Staff/admin-only sections — block visitors.
      if (loc.startsWith('/staff') && !isStaffOrAdmin) return '/home';

      return null;
    },
  );
}
