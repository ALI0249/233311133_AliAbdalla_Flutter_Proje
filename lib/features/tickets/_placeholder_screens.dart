import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Temporary placeholder — replaced by real ticket screens in commit 4.
class TicketsPlaceholderScreen extends StatelessWidget {
  const TicketsPlaceholderScreen({super.key, required this.title, this.body});
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 64, color: Color(0xFF8B4513)),
              const SizedBox(height: 16),
              Text(
                body ?? 'Bu ekran sonraki adımda hazır olacak.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
