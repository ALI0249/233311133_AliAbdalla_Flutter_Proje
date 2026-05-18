import '../../core/supabase_client.dart';
import 'museum_model.dart';

class MuseumService {
  Future<List<Museum>> fetchAll() async {
    final data = await supabase
        .from('museums')
        .select()
        .order('name');
    return (data as List)
        .map((m) => Museum.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<Museum?> fetchById(String id) async {
    final data = await supabase
        .from('museums')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return Museum.fromMap(data);
  }

  Future<List<Exhibition>> fetchExhibitionsForMuseum(String museumId) async {
    final data = await supabase
        .from('exhibitions')
        .select()
        .eq('museum_id', museumId)
        .order('start_date');
    return (data as List)
        .map((e) => Exhibition.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Museum>> search(String query) async {
    final data = await supabase
        .from('museums')
        .select()
        .or('name.ilike.%$query%,city.ilike.%$query%')
        .order('name');
    return (data as List)
        .map((m) => Museum.fromMap(m as Map<String, dynamic>))
        .toList();
  }
}
