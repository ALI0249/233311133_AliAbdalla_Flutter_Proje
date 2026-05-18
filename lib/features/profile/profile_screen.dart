import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/logger.dart';
import '../../core/theme.dart';
import '../auth/auth_state.dart';
import 'profile_model.dart';
import 'profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _editing = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = context.read<AuthState>().profile;
    _nameCtrl.text = p?.fullName ?? '';
    _phoneCtrl.text = p?.phone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthState>().user?.id;
    if (userId == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.updateOwnProfile(
        userId: userId,
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      await AppLogger.log('profile.update');
      if (!mounted) return;
      setState(() {
        _editing = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  void _backToHome() {
    final p = context.read<AuthState>().profile;
    if (p?.isStaffOrAdmin ?? false) {
      context.go('/staff');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final profile = auth.profile;
    final isStaffOrAdmin = profile?.isStaffOrAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backToHome,
        ),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        AppTheme.primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.account_circle,
                        size: 64, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                _section('Rol', _roleLabel(profile?.role)),
                _section('E-posta', auth.user?.email ?? '-'),
                const SizedBox(height: 8),
                _editing ? _buildEditForm() : _buildReadOnly(profile),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 24),
                if (_editing)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => setState(() => _editing = false),
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : const Icon(Icons.save),
                          label: const Text('Kaydet'),
                          onPressed: _saving ? null : _save,
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Çıkış Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                      onPressed: () async {
                        await context.read<AuthState>().signOut();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ),
                if (!_editing && isStaffOrAdmin) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.dashboard),
                      label: const Text('Panele Dön'),
                      onPressed: () => context.go('/staff'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Yönetici';
      case 'personel':
        return 'Personel';
      case 'ziyaretci':
        return 'Ziyaretçi';
      default:
        return '-';
    }
  }

  Widget _section(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildReadOnly(Profile? profile) {
    return Column(
      children: [
        _section('Ad Soyad', profile?.fullName ?? '-'),
        _section('Telefon', profile?.phone ?? '-'),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Ad Soyad'),
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              v == null || v.trim().length < 3 ? 'En az 3 karakter' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneCtrl,
          decoration: const InputDecoration(labelText: 'Telefon'),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
