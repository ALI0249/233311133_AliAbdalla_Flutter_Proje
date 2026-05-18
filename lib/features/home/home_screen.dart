import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../artifacts/artifact_model.dart';
import '../artifacts/artifact_service.dart';
import '../auth/auth_state.dart';
import '../museums/museum_model.dart';
import '../museums/museum_service.dart';
import '../museums/occupancy_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _museumService = MuseumService();
  final _artifactService = ArtifactService();
  final _occupancyService = OccupancyService();

  Museum? _museum;
  Occupancy? _occupancy;
  List<Artifact>? _featured;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final museums = await _museumService.fetchAll();
      final museum = museums.isNotEmpty ? museums.first : null;
      final occupancy = await _occupancyService.fetchTheMuseum();
      final featured = await _artifactService.fetchFeatured(limit: 3);
      if (!mounted) return;
      setState(() {
        _museum = museum;
        _occupancy = occupancy;
        _featured = featured;
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
    final auth = context.watch<AuthState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müzem'),
        actions: [
          IconButton(
            tooltip: 'Biletlerim',
            icon: const Icon(Icons.confirmation_number_outlined),
            onPressed: () => context.go('/tickets'),
          ),
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: _buildBody(auth),
    );
  }

  Widget _buildBody(AuthState auth) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Tekrar dene')),
            ],
          ),
        ),
      );
    }
    final m = _museum;
    if (m == null) {
      return const Center(child: Text('Müze bilgisi bulunamadı.'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // greeting
          if (auth.profile?.fullName.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Hoş geldin, ${auth.profile!.fullName}',
                style: const TextStyle(color: AppTheme.textMuted),
              ),
            ),
          // hero / museum card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.museum,
                            color: AppTheme.primary, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700)),
                            if (m.city != null)
                              Text(m.city!,
                                  style: const TextStyle(
                                      color: AppTheme.textMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (m.description != null) ...[
                    const SizedBox(height: 12),
                    Text(m.description!,
                        style: const TextStyle(height: 1.4)),
                  ],
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => context.go('/museum/${m.id}'),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Müze Hakkında Detaylar'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // occupancy gauge
          if (_occupancy != null) _OccupancyCard(occupancy: _occupancy!),
          if (_occupancy != null) const SizedBox(height: 16),

          // CTA: Bilet Al
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.confirmation_number),
              label: const Text('Bilet Al'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => context.go('/tickets/buy?museumId=${m.id}'),
            ),
          ),
          const SizedBox(height: 24),

          // Featured artifacts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Öne Çıkan Eserler',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () => context.go('/artifacts'),
                child: const Text('Tümünü Gör'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...?_featured?.map((a) => _ArtifactPreviewCard(artifact: a)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard({required this.occupancy});
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
                const Text('Müze Anlık Doluluk',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  '%${occupancy.fillPercent}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _color()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: occupancy.fillRatio,
                minHeight: 12,
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

class _ArtifactPreviewCard extends StatelessWidget {
  const _ArtifactPreviewCard({required this.artifact});
  final Artifact artifact;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/artifacts/${artifact.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppTheme.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(artifact.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Pill(text: artifact.category),
                        if (artifact.era != null) ...[
                          const SizedBox(width: 6),
                          Text(artifact.era!,
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: const TextStyle(
              color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
