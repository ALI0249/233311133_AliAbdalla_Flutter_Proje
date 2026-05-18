import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Network image with consistent loading + error fallbacks across the app.
/// When [url] is null or the request fails, renders [fallbackIcon] on a
/// branded gradient — visually consistent with the rest of the UI.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    this.fallbackIcon = Icons.auto_awesome,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final IconData fallbackIcon;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (url == null || url!.isEmpty) {
      child = _placeholder();
    } else {
      child = Image.network(
        url!,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppTheme.background,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  color: AppTheme.primary, strokeWidth: 2.5),
            ),
          );
        },
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    }
    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.6),
            AppTheme.accent.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(fallbackIcon, size: 48, color: Colors.white),
    );
  }
}
