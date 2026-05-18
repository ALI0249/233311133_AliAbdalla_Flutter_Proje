import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import 'admin_service.dart';

class SystemLogsScreen extends StatefulWidget {
  const SystemLogsScreen({super.key});

  @override
  State<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends State<SystemLogsScreen> {
  final _service = AdminService();
  Future<List<LogEntry>>? _future;
  String? _filterAction;

  static const _knownActions = [
    'auth.login',
    'auth.logout',
    'auth.register',
    'ticket.purchase',
    'ticket.scan',
    'admin.role_change',
  ];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.fetchLogs(action: _filterAction);
    });
  }

  IconData _iconFor(String action) {
    if (action.startsWith('auth.login')) return Icons.login;
    if (action.startsWith('auth.logout')) return Icons.logout;
    if (action.startsWith('auth.register')) return Icons.person_add;
    if (action.startsWith('ticket.purchase')) return Icons.shopping_cart;
    if (action.startsWith('ticket.scan')) return Icons.qr_code_scanner;
    if (action.startsWith('admin.')) return Icons.admin_panel_settings;
    return Icons.bolt;
  }

  Color _colorFor(String action) {
    if (action.contains('purchase')) return Colors.green.shade700;
    if (action.contains('scan')) return AppTheme.primary;
    if (action.startsWith('admin')) return Colors.red.shade700;
    return AppTheme.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM HH:mm:ss', 'tr_TR');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Logları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
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
                _chip('Tümü', null),
                for (final a in _knownActions) _chip(a, a),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LogEntry>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                final logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  return const Center(child: Text('Log kaydı bulunamadı.'));
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: logs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final l = logs[i];
                    return Card(
                      child: ListTile(
                        dense: true,
                        leading: Icon(_iconFor(l.action),
                            color: _colorFor(l.action)),
                        title: Text(l.action,
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fmt.format(l.createdAt.toLocal()),
                                style: const TextStyle(fontSize: 11)),
                            if (l.userFullName != null)
                              Text('Kullanıcı: ${l.userFullName}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted)),
                            if (l.metadata != null)
                              Text(l.metadata.toString(),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _filterAction == value,
        onSelected: (_) {
          setState(() => _filterAction = value);
          _reload();
        },
        selectedColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: _filterAction == value ? Colors.white : AppTheme.textDark,
        ),
      ),
    );
  }
}
