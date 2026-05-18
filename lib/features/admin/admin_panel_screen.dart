import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../auth/auth_state.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetici Paneli'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/staff'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Hoş geldin, ${auth.profile?.fullName ?? 'Yönetici'}',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ),
          _AdminTile(
            icon: Icons.manage_accounts,
            title: 'Personel Yönetimi',
            subtitle: 'Kullanıcıların rollerini görüntüle ve değiştir',
            onTap: () => context.go('/admin/staff'),
          ),
          _AdminTile(
            icon: Icons.list_alt,
            title: 'Sistem Logları',
            subtitle: 'Tüm sistemde gerçekleşen işlemlerin kaydı',
            onTap: () => context.go('/admin/logs'),
          ),
          _AdminTile(
            icon: Icons.museum,
            title: 'Eser Yönetimi',
            subtitle: 'Müzedeki eserleri ekle, düzenle, sil',
            onTap: () => context.go('/staff/artifacts'),
          ),
          _AdminTile(
            icon: Icons.bar_chart,
            title: 'Detaylı İstatistikler',
            subtitle: 'Günlük ve haftalık ziyaretçi raporları',
            onTap: () => context.go('/staff/stats'),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
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
