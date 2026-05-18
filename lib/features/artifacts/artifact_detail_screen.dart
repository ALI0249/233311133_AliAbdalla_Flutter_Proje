import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme.dart';
import '../../shared/widgets/remote_image.dart';
import 'artifact_model.dart';
import 'artifact_service.dart';

class ArtifactDetailScreen extends StatefulWidget {
  const ArtifactDetailScreen({super.key, required this.artifactId});
  final String artifactId;

  @override
  State<ArtifactDetailScreen> createState() => _ArtifactDetailScreenState();
}

class _ArtifactDetailScreenState extends State<ArtifactDetailScreen> {
  final _service = ArtifactService();
  Artifact? _artifact;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final a = await _service.fetchById(widget.artifactId);
      if (!mounted) return;
      setState(() {
        _artifact = a;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_artifact?.name ?? 'Eser'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/artifacts'),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    final a = _artifact;
    if (a == null) return const Center(child: Text('Eser bulunamadı.'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero image
        SizedBox(
          height: 240,
          width: double.infinity,
          child: RemoteImage(
            url: a.imageUrl,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        Text(a.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(a.category,
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
            if (a.era != null) ...[
              const SizedBox(width: 10),
              Text(a.era!,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 13)),
            ],
          ],
        ),
        if (a.locationInMuseum != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Expanded(child: Text(a.locationInMuseum!)),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (a.description != null)
          Text(a.description!,
              style: const TextStyle(height: 1.5, fontSize: 15)),
        const SizedBox(height: 24),
        // QR code card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Eser QR Kodu',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                const Text(
                  'Müzedeki bu eserin yanındaki kart üzerindeki QR kod ile aynıdır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: a.qrPayload,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppTheme.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(a.qrPayload,
                    style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontFamily: 'monospace')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
