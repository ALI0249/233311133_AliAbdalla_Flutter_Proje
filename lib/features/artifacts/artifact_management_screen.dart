import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../museums/museum_service.dart';
import 'artifact_model.dart';
import 'artifact_service.dart';

class ArtifactManagementScreen extends StatefulWidget {
  const ArtifactManagementScreen({super.key});

  @override
  State<ArtifactManagementScreen> createState() =>
      _ArtifactManagementScreenState();
}

class _ArtifactManagementScreenState extends State<ArtifactManagementScreen> {
  final _service = ArtifactService();
  final _museumService = MuseumService();
  Future<List<Artifact>>? _future;
  String? _museumId;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final museums = await _museumService.fetchAll();
    if (museums.isNotEmpty) _museumId = museums.first.id;
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.fetchAll();
    });
  }

  Future<void> _openForm({Artifact? existing}) async {
    if (_museumId == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _ArtifactForm(
          museumId: _museumId!,
          existing: existing,
        ),
      ),
    );
    if (saved == true) _reload();
  }

  Future<void> _confirmDelete(Artifact a) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eseri sil?'),
        content: Text('"${a.name}" eserini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sil')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _service.delete(a.id);
        _reload();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eser Yönetimi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/staff'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Yeni Eser'),
        onPressed: () => _openForm(),
      ),
      body: FutureBuilder<List<Artifact>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Henüz eser eklenmemiş.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = items[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.auto_awesome,
                      color: AppTheme.primary),
                  title: Text(a.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${a.category}'
                      '${a.era != null ? '  •  ${a.era}' : ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openForm(existing: a),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(a),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ArtifactForm extends StatefulWidget {
  const _ArtifactForm({required this.museumId, this.existing});
  final String museumId;
  final Artifact? existing;

  @override
  State<_ArtifactForm> createState() => _ArtifactFormState();
}

class _ArtifactFormState extends State<_ArtifactForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = ArtifactService();

  late final TextEditingController _name;
  late final TextEditingController _era;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late String _category;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _era = TextEditingController(text: e?.era ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _location = TextEditingController(text: e?.locationInMuseum ?? '');
    _category = e?.category ?? kArtifactCategories.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _era.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.existing == null) {
        await _service.create(
          museumId: widget.museumId,
          name: _name.text.trim(),
          category: _category,
          era: _era.text.trim().isEmpty ? null : _era.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          locationInMuseum: _location.text.trim().isEmpty
              ? null
              : _location.text.trim(),
        );
      } else {
        await _service.update(
          id: widget.existing!.id,
          name: _name.text.trim(),
          category: _category,
          era: _era.text.trim().isEmpty ? null : _era.text.trim(),
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          locationInMuseum: _location.text.trim().isEmpty
              ? null
              : _location.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Eseri Düzenle' : 'Yeni Eser')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Adı *'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Eser adı zorunlu'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration:
                    const InputDecoration(labelText: 'Kategori *'),
                items: [
                  for (final c in kArtifactCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _era,
                decoration:
                    const InputDecoration(labelText: 'Dönem (örn. 17. yüzyıl)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                    labelText: 'Müze içindeki yeri'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration:
                    const InputDecoration(labelText: 'Açıklama'),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(isEdit ? 'Kaydet' : 'Ekle'),
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
