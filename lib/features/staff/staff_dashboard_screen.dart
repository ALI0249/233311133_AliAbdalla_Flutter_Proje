import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../auth/auth_state.dart';
import '../museums/occupancy_service.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final _occupancyService = OccupancyService();
  Occupancy? _occupancy;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final o = await _occupancyService.fetchTheMuseum();
      if (!mounted) return;
      setState(() {
        _occupancy = o;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final isAdmin = auth.profile?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Paneli'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (auth.profile?.fullName.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Hoş geldin, ${auth.profile!.fullName} '
                  '(${isAdmin ? 'Yönetici' : 'Personel'})',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_occupancy != null)
              _StaffOccupancyCard(occupancy: _occupancy!),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.qr_code_scanner,
              title: 'Bilet Tara',
              subtitle: 'Giriş ve çıkışlar için QR doğrulama',
              onTap: () => context.go('/staff/scan'),
            ),
            _ActionTile(
              icon: Icons.bar_chart,
              title: 'Bugünkü İstatistikler',
              subtitle: 'Saatlik ve günlük ziyaretçi grafikleri',
              onTap: () => context.go('/staff/stats'),
            ),
            _ActionTile(
              icon: Icons.museum,
              title: 'Eser Yönetimi',
              subtitle: 'Eser ekle, düzenle, sil',
              onTap: () => context.go('/staff/artifacts'),
            ),
            if (isAdmin)
              _ActionTile(
                icon: Icons.admin_panel_settings,
                title: 'Yönetici Paneli',
                subtitle: 'Personel yönetimi, sistem logları, gelişmiş raporlar',
                onTap: () => context.go('/admin'),
                highlight: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _StaffOccupancyCard extends StatelessWidget {
  const _StaffOccupancyCard({required this.occupancy});
  final Occupancy occupancy;

  Color _color() {
    if (occupancy.fillRatio < 0.5) return Colors.green;
    if (occupancy.fillRatio < 0.8) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: _color()),
                const SizedBox(width: 8),
                Text(occupancy.name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('%${occupancy.fillPercent}',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _color())),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: occupancy.fillRatio,
                minHeight: 14,
                backgroundColor: AppTheme.background,
                color: _color(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${occupancy.currentVisitors} / ${occupancy.capacity} ziyaretçi şu an müzede',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight ? AppTheme.accent.withValues(alpha: 0.18) : null,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 30),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
