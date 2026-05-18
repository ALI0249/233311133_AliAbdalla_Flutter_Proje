import '../../core/supabase_client.dart';

class Occupancy {
  final String museumId;
  final String name;
  final int capacity;
  final int currentVisitors;

  const Occupancy({
    required this.museumId,
    required this.name,
    required this.capacity,
    required this.currentVisitors,
  });

  double get fillRatio =>
      capacity == 0 ? 0 : (currentVisitors / capacity).clamp(0.0, 1.0);

  int get fillPercent => (fillRatio * 100).round();

  factory Occupancy.fromMap(Map<String, dynamic> map) {
    return Occupancy(
      museumId: map['museum_id'] as String,
      name: map['name'] as String,
      capacity: (map['capacity'] as num).toInt(),
      currentVisitors: (map['current_visitors'] as num).toInt(),
    );
  }
}

class OccupancyService {
  Future<Occupancy?> fetchFor(String museumId) async {
    final data = await supabase
        .from('occupancy')
        .select()
        .eq('museum_id', museumId)
        .maybeSingle();
    if (data == null) return null;
    return Occupancy.fromMap(data);
  }

  /// For the single-museum app: returns the first row (and only row).
  Future<Occupancy?> fetchTheMuseum() async {
    final data =
        await supabase.from('occupancy').select().limit(1).maybeSingle();
    if (data == null) return null;
    return Occupancy.fromMap(data);
  }
}
