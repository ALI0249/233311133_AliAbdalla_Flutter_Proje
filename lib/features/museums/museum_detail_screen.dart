import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import 'museum_model.dart';
import 'museum_service.dart';

class MuseumDetailScreen extends StatefulWidget {
  const MuseumDetailScreen({super.key, required this.museumId});
  final String museumId;

  @override
  State<MuseumDetailScreen> createState() => _MuseumDetailScreenState();
}

class _MuseumDetailScreenState extends State<MuseumDetailScreen> {
  final _service = MuseumService();
  Museum? _museum;
  List<Exhibition>? _exhibitions;
  String? _error;
  bool _loading = true;

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
      final m = await _service.fetchById(widget.museumId);
      final ex = await _service.fetchExhibitionsForMuseum(widget.museumId);
      if (!mounted) return;
      setState(() {
        _museum = m;
        _exhibitions = ex;
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
        title: Text(_museum?.name ?? 'Müze'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/museums'),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _museum == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.confirmation_number),
                  label: const Text('Bilet Al'),
                  onPressed: () =>
                      context.go('/tickets/buy?museumId=${widget.museumId}'),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
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
              ElevatedButton(
                onPressed: _load,
                child: const Text('Tekrar dene'),
              ),
            ],
          ),
        ),
      );
    }
    if (_museum == null) {
      return const Center(child: Text('Müze bulunamadı.'));
    }

    final m = _museum!;
    final exhibitions = _exhibitions ?? [];
    final fmt = DateFormat('dd MMM yyyy', 'tr_TR');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.museum,
                          color: AppTheme.primary, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                          if (m.city != null) ...[
                            const SizedBox(height: 4),
                            Text(m.city!,
                                style: const TextStyle(
                                    color: AppTheme.textMuted)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (m.address != null)
                  _detailRow(Icons.location_on_outlined, 'Adres', m.address!),
                if (m.openingHours != null)
                  _detailRow(Icons.schedule, 'Çalışma saatleri', m.openingHours!),
                if (m.description != null) ...[
                  const SizedBox(height: 8),
                  Text(m.description!,
                      style: const TextStyle(height: 1.4)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Sergiler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
        const SizedBox(height: 8),
        if (exhibitions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Bu müzede aktif sergi bulunmuyor.'),
            ),
          )
        else
          ...exhibitions.map(
            (e) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    if (e.startDate != null && e.endDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${fmt.format(e.startDate!)} – ${fmt.format(e.endDate!)}',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                    if (e.description != null) ...[
                      const SizedBox(height: 8),
                      Text(e.description!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
