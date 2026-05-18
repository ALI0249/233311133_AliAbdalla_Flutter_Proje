import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lightweight placeholders for staff/admin screens that land in commits 7-8.
class StaffPlaceholderScreen extends StatelessWidget {
  const StaffPlaceholderScreen({
    super.key,
    required this.title,
    required this.commitNote,
    this.backPath = '/staff',
  });

  final String title;
  final String commitNote;
  final String backPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(backPath),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction,
                  size: 64, color: Color(0xFF8B4513)),
              const SizedBox(height: 16),
              Text(commitNote, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
