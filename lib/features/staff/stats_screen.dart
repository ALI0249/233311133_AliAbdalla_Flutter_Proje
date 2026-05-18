import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import 'stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _service = StatsService();
  TodayStats? _today;
  List<DailyCount>? _weekly;
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
      final today = await _service.fetchTodayStats();
      final weekly = await _service.fetchDailyEntries(days: 7);
      if (!mounted) return;
      setState(() {
        _today = today;
        _weekly = weekly;
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
        title: const Text('İstatistikler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/staff'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Hata: $_error'));
    final t = _today;
    final w = _weekly ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI row
          Row(
            children: [
              Expanded(
                child: _Kpi(
                  label: 'Bugünkü Giriş',
                  value: '${t?.entries ?? 0}',
                  icon: Icons.login,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Kpi(
                  label: 'Şu An Müzede',
                  value: '${t?.currentlyInside ?? 0}',
                  icon: Icons.groups,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Kpi(
                  label: 'Bugün Satılan',
                  value: '${t?.ticketsSoldToday ?? 0}',
                  icon: Icons.confirmation_number,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Haftalık Ziyaretçi Girişi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(height: 240, child: _WeeklyBarChart(data: w)),
          const SizedBox(height: 24),
          const Text('Detay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...w.map(_dailyRow),
        ],
      ),
    );
  }

  Widget _dailyRow(DailyCount d) {
    final fmt = DateFormat('EEEE, dd MMM', 'tr_TR');
    return Card(
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.calendar_today,
            size: 18, color: AppTheme.textMuted),
        title: Text(fmt.format(d.day)),
        trailing: Text('${d.count}',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary)),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.data});
  final List<DailyCount> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Veri yok.'));
    final maxY = (data.map((d) => d.count).fold<int>(0, (a, b) => a > b ? a : b))
        .toDouble()
        .clamp(1.0, double.infinity);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxY * 1.3).ceilToDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                final fmt = DateFormat('E', 'tr_TR');
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(fmt.format(data[i].day),
                      style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].count.toDouble(),
                  color: AppTheme.primary,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
