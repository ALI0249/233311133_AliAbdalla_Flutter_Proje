import '../../core/supabase_client.dart';
import 'artifact_model.dart';

class ArtifactService {
  Future<List<Artifact>> fetchAll({String? category, String? query}) async {
    var builder = supabase.from('artifacts').select();
    if (category != null) builder = builder.eq('category', category);
    if (query != null && query.isNotEmpty) {
      builder = builder.ilike('name', '%$query%');
    }
    final data = await builder.order('name');
    return (data as List)
        .map((a) => Artifact.fromMap(a as Map<String, dynamic>))
        .toList();
  }

  Future<Artifact?> fetchById(String id) async {
    final data = await supabase
        .from('artifacts')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return Artifact.fromMap(data);
  }

  Future<List<Artifact>> fetchFeatured({int limit = 3}) async {
    final data = await supabase
        .from('artifacts')
        .select()
        .limit(limit);
    return (data as List)
        .map((a) => Artifact.fromMap(a as Map<String, dynamic>))
        .toList();
  }

  Future<Artifact> create({
    required String museumId,
    required String name,
    required String category,
    String? era,
    String? description,
    String? locationInMuseum,
  }) async {
    final qr = 'art-${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    final data = await supabase
        .from('artifacts')
        .insert({
          'museum_id': museumId,
          'name': name,
          'category': category,
          'era': era,
          'description': description,
          'location_in_museum': locationInMuseum,
          'qr_payload': qr,
        })
        .select()
        .single();
    return Artifact.fromMap(data);
  }

  Future<Artifact> update({
    required String id,
    required String name,
    required String category,
    String? era,
    String? description,
    String? locationInMuseum,
  }) async {
    final data = await supabase
        .from('artifacts')
        .update({
          'name': name,
          'category': category,
          'era': era,
          'description': description,
          'location_in_museum': locationInMuseum,
        })
        .eq('id', id)
        .select()
        .single();
    return Artifact.fromMap(data);
  }

  Future<void> delete(String id) async {
    await supabase.from('artifacts').delete().eq('id', id);
  }
}
