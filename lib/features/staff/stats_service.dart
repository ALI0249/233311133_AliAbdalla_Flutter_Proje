import '../../core/supabase_client.dart';

class TodayStats {
  final int entries;
  final int currentlyInside;
  final int ticketsSoldToday;

  const TodayStats({
    required this.entries,
    required this.currentlyInside,
    required this.ticketsSoldToday,
  });
}

class DailyCount {
  final DateTime day;
  final int count;
  const DailyCount({required this.day, required this.count});
}

class StatsService {
  /// Today's entries, currently-inside, and tickets sold today.
  Future<TodayStats> fetchTodayStats() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startIso = startOfToday.toUtc().toIso8601String();

    final entriesData = await supabase
        .from('visits')
        .select('id')
        .gte('entered_at', startIso);

    final occ = await supabase
        .from('occupancy')
        .select('current_visitors')
        .limit(1)
        .maybeSingle();

    final ticketsData = await supabase
        .from('tickets')
        .select('id')
        .gte('created_at', startIso);

    return TodayStats(
      entries: (entriesData as List).length,
      currentlyInside:
          occ == null ? 0 : (occ['current_visitors'] as num).toInt(),
      ticketsSoldToday: (ticketsData as List).length,
    );
  }

  /// Per-day entry count for the last [days] days (oldest first).
  /// Computed client-side to avoid a server-side SQL function — small data.
  Future<List<DailyCount>> fetchDailyEntries({int days = 7}) async {
    final now = DateTime.now();
    final since = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final data = await supabase
        .from('visits')
        .select('entered_at')
        .gte('entered_at', since.toUtc().toIso8601String());

    final buckets = <DateTime, int>{};
    for (var i = 0; i < days; i++) {
      final d = since.add(Duration(days: i));
      buckets[DateTime(d.year, d.month, d.day)] = 0;
    }
    for (final row in (data as List)) {
      final ts = DateTime.parse(row['entered_at'] as String).toLocal();
      final day = DateTime(ts.year, ts.month, ts.day);
      buckets[day] = (buckets[day] ?? 0) + 1;
    }
    final result = buckets.entries
        .map((e) => DailyCount(day: e.key, count: e.value))
        .toList();
    result.sort((a, b) => a.day.compareTo(b.day));
    return result;
  }
}
