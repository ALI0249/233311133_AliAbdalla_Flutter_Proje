import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../auth/auth_state.dart';
import '../profile/profile_model.dart';
import 'admin_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final _service = AdminService();
  Future<List<Profile>>? _future;
  String _filter = 'tumu';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.fetchAllProfiles();
    });
  }

  Future<void> _changeRole(Profile p, String newRole) async {
    final myId = context.read<AuthState>().user?.id;
    if (myId == p.id && newRole != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kendi yönetici rolünüzü düşüremezsiniz.')),
      );
      return;
    }
    try {
      await _service.updateProfileRole(
          profileId: p.id, newRole: newRole);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${p.fullName} → $newRole')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  List<Profile> _applyFilter(List<Profile> all) {
    if (_filter == 'tumu') return all;
    return all.where((p) => p.role == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Yönetimi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filterChip('Tümü', 'tumu'),
                _filterChip('Yönetici', 'admin'),
                _filterChip('Personel', 'personel'),
                _filterChip('Ziyaretçi', 'ziyaretci'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Profile>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                final list = _applyFilter(snapshot.data ?? []);
                if (list.isEmpty) {
                  return const Center(child: Text('Kullanıcı bulunamadı.'));
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _ProfileTile(profile: list[i], onChangeRole: _changeRole),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: _filter == value ? Colors.white : AppTheme.textDark,
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.profile, required this.onChangeRole});
  final Profile profile;
  final Future<void> Function(Profile, String) onChangeRole;

  Color _roleColor() {
    if (profile.isAdmin) return Colors.red.shade700;
    if (profile.isPersonel) return AppTheme.primary;
    return AppTheme.textMuted;
  }

  IconData _roleIcon() {
    if (profile.isAdmin) return Icons.admin_panel_settings;
    if (profile.isPersonel) return Icons.badge;
    return Icons.person;
  }

  String _roleLabel() {
    if (profile.isAdmin) return 'Yönetici';
    if (profile.isPersonel) return 'Personel';
    return 'Ziyaretçi';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _roleColor().withValues(alpha: 0.15),
                  child: Icon(_roleIcon(), color: _roleColor(), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.fullName,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      if (profile.phone != null)
                        Text(profile.phone!,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _roleColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _roleLabel(),
                    style: TextStyle(
                      color: _roleColor(),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: profile.isZiyaretci
                        ? null
                        : () => onChangeRole(profile, 'ziyaretci'),
                    child: const Text('Ziyaretçi'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    onPressed: profile.isPersonel
                        ? null
                        : () => onChangeRole(profile, 'personel'),
                    child: const Text('Personel'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    onPressed: profile.isAdmin
                        ? null
                        : () => onChangeRole(profile, 'admin'),
                    child: const Text('Yönetici'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
