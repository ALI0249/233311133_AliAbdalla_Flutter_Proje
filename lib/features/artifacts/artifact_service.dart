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
}
