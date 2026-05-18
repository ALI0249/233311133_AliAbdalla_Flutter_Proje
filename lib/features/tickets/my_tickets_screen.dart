import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../auth/auth_state.dart';
import 'ticket_model.dart';
import 'ticket_qr_card.dart';
import 'ticket_service.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final _service = TicketService();
  Future<List<Ticket>>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final userId = context.read<AuthState>().user?.id;
    if (userId == null) return;
    setState(() {
      _future = _service.fetchMyTickets(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biletlerim'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.confirmation_number_outlined,
                        size: 64, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'Henüz bir biletiniz yok.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Bilet Al'),
                      onPressed: () => context.go('/tickets/buy'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tickets.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: TicketQrCard(ticket: tickets[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}
