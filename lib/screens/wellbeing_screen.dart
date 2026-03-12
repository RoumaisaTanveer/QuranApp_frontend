// lib/screens/wellbeing_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class WellbeingScreen extends StatefulWidget {
  const WellbeingScreen({super.key});

  @override
  State<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends State<WellbeingScreen> {
  List<HistoryItem> _history = [];
  bool _loading = true;
  int _days = 30;

  final _pos = const {'grateful','hopeful','peaceful','happy','content'};
  final _neg = const {'anxious','stressed','sad','lonely','heartbroken','angry','tired'};

  @override
  void initState() { super.initState(); }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final h = await ApiService.getHistory();
      setState(() => _history = h);
    } catch (_) {} finally {
      setState(() => _loading = false);
    }
  }

  List<HistoryItem> get _filtered {
    if (_days == 999) return _history;
    final cutoff = DateTime.now().subtract(Duration(days: _days));
    return _history.where((h) {
      try { return DateTime.parse(h.timestamp).isAfter(cutoff); } catch (_) { return true; }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Wellbeing', style: AppText.label(size: 14, spacing: 2.5)),
      ),
      body: _loading
          ? const Center(child: LoadingDots())
          : RefreshIndicator(
              color: AppColors.purple,
              backgroundColor: AppColors.card,
              onRefresh: _load,
              child: _filtered.isEmpty
                  ? const EmptyState(
                      arabic: 'رحلتك',
                      message: 'Start journaling to see your emotional journey.',
                    )
                  : _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    final h = _filtered;
    final total = h.length;
    final posCount = h.where((x) => _pos.contains(x.emotionBefore)).length;
    final posRate = total > 0 ? (posCount / total * 100).round() : 0;
    final improved = h.where((x) =>
        x.emotionAfter != null &&
        _pos.contains(x.emotionAfter) &&
        _neg.contains(x.emotionBefore)).length;

    final freq = <String, int>{};
    for (final x in h) freq[x.emotionBefore] = (freq[x.emotionBefore] ?? 0) + 1;
    final dominant = freq.isEmpty ? null
        : freq.entries.reduce((a, b) => a.value > b.value ? a : b);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          _periodRow().animate().fadeIn(),
          const SizedBox(height: 20),

          // Stats
          _statsRow(total, posRate, improved, dominant)
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),

          // Insight
          if (dominant != null)
            _insightCard(dominant.key, improved, posRate)
                .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),

          // Charts
          _chartCard(
            title: 'Emotional Arc',
            subtitle: 'How you feel before and after each reading',
            child: SizedBox(height: 170, child: _lineChart(h)),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 14),

          _chartCard(
            title: 'Emotion Breakdown',
            subtitle: 'Your most frequent emotional states',
            child: SizedBox(height: 210, child: _pieChart(freq)),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 14),

          _chartCard(
            title: 'Reading Impact',
            subtitle: 'Did the Quran shift your heart?',
            child: SizedBox(height: 170, child: _barChart(h)),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _periodRow() => Row(
    children: {'7 Days': 7, '30 Days': 30, 'All Time': 999}.entries.map((e) =>
      GestureDetector(
        onTap: () => setState(() => _days = e.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _days == e.value ? AppColors.purple : AppColors.card,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: _days == e.value ? AppColors.purple : AppColors.border,
            ),
          ),
          child: Text(e.key,
            style: AppText.label(
              size: 9,
              color: _days == e.value ? AppColors.bg : AppColors.textMuted,
              spacing: 0.5,
            ),
          ),
        ),
      ),
    ).toList(),
  );

  Widget _statsRow(int total, int posRate, int improved, MapEntry<String, int>? dominant) =>
    Row(children: [
      _StatCard(label: 'Total', value: '$total', sub: 'entries'),
      const SizedBox(width: 10),
      _StatCard(label: 'Positive', value: '$posRate%', sub: 'of entries'),
      const SizedBox(width: 10),
      _StatCard(label: 'Shifts', value: '$improved', sub: 'improved'),
      const SizedBox(width: 10),
      _StatCard(
        label: 'Top',
        value: dominant?.key ?? '—',
        sub: '${dominant?.value ?? 0}×',
        small: true,
      ),
    ]);

  Widget _insightCard(String emotion, int improved, int posRate) {
    String icon, title, body;
    if (posRate >= 60) {
      icon = '🌿'; title = 'Your heart is in a good place';
      body = '$posRate% of your entries reflect positivity. Alhamdulillah.';
    } else if (improved >= 3) {
      icon = '🤍'; title = 'The Quran is moving your heart';
      body = '$improved times you came heavy and left lighter.';
    } else {
      icon = '🌙'; title = 'You\'ve been feeling $emotion lately';
      body = 'The fact that you\'re here, seeking, is itself a form of worship.';
    }
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.purpleDim,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.sans(size: 15, color: AppColors.purpleLight)),
          const SizedBox(height: 4),
          Text(body, style: AppText.sans(size: 13, italic: true, color: AppColors.textDim)),
        ])),
      ]),
    );
  }

  Widget _chartCard({required String title, required String subtitle, required Widget child}) =>
    AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppText.label(size: 11, spacing: 1.5)),
        const SizedBox(height: 3),
        Text(subtitle, style: AppText.sans(size: 12, italic: true, color: AppColors.textDim)),
        const SizedBox(height: 16),
        child,
      ]),
    );

  Widget _lineChart(List<HistoryItem> h) {
    int score(String? e) {
      if (e == null) return 0;
      if (_pos.contains(e)) return 1;
      if (_neg.contains(e)) return -1;
      return 0;
    }
    final before = h.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), score(e.value.emotionBefore).toDouble()))
        .toList();
    final after = h.asMap().entries
        .where((e) => e.value.emotionAfter != null)
        .map((e) => FlSpot(e.key.toDouble(), score(e.value.emotionAfter).toDouble()))
        .toList();

    return LineChart(LineChartData(
      backgroundColor: Colors.transparent,
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5),
        getDrawingVerticalLine: (_) => FlLine(color: Colors.transparent),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 55,
          getTitlesWidget: (v, _) {
            if (v == 1)  return Text('Positive', style: AppText.label(size: 7, color: AppColors.green, spacing: 0));
            if (v == 0)  return Text('Neutral',  style: AppText.label(size: 7, color: AppColors.textMuted, spacing: 0));
            if (v == -1) return Text('Heavy',    style: AppText.label(size: 7, color: AppColors.red, spacing: 0));
            return const SizedBox.shrink();
          },
        )),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles:const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      minY: -1.5, maxY: 1.5,
      lineBarsData: [
        LineChartBarData(
          spots: before, isCurved: true,
          color: AppColors.red.withOpacity(0.8), barWidth: 2,
          dotData: FlDotData(getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
            radius: 4,
            color: s.y >= 0 ? AppColors.green : AppColors.red,
            strokeWidth: 0,
          )),
          belowBarData: BarAreaData(show: true, color: AppColors.red.withOpacity(0.04)),
        ),
        if (after.isNotEmpty) LineChartBarData(
          spots: after, isCurved: true,
          color: AppColors.green.withOpacity(0.7), barWidth: 1.5,
          dashArray: [4, 4],
          dotData: FlDotData(getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
            radius: 3, color: AppColors.green, strokeWidth: 0,
          )),
        ),
      ],
    ));
  }

  Widget _pieChart(Map<String, int> freq) {
    if (freq.isEmpty) return const SizedBox.shrink();
    final total = freq.values.fold(0, (a, b) => a + b);
    return PieChart(PieChartData(
      sections: freq.entries.map((e) {
        final color = Color(EmotionMeta.getColor(e.key));
        return PieChartSectionData(
          value: e.value.toDouble(),
          color: color.withOpacity(0.85),
          title: e.value / total > 0.08 ? e.key : '',
          titleStyle: AppText.label(size: 8, color: Colors.white, spacing: 0),
          radius: 75,
          borderSide: const BorderSide(color: AppColors.bg, width: 2),
        );
      }).toList(),
      centerSpaceRadius: 30,
      sectionsSpace: 0,
      pieTouchData: PieTouchData(enabled: false),
    ));
  }

  Widget _barChart(List<HistoryItem> h) {
    final withAfter = h.where((x) => x.emotionAfter != null).toList();
    final improved = withAfter.where((x) =>
        _pos.contains(x.emotionAfter) && _neg.contains(x.emotionBefore)).length;
    final same    = withAfter.length - improved;
    final noAfter = h.length - withAfter.length;

    return BarChart(BarChartData(
      backgroundColor: Colors.transparent,
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5),
        getDrawingVerticalLine: (_) => FlLine(color: Colors.transparent),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 36,
          getTitlesWidget: (v, _) {
            const l = ['Improved', 'Same', 'No data'];
            if (v.toInt() < l.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l[v.toInt()],
                  style: AppText.label(size: 8, color: AppColors.textDim, spacing: 0),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 22,
          getTitlesWidget: (v, _) => Text('${v.toInt()}',
            style: AppText.label(size: 8, color: AppColors.textMuted, spacing: 0),
          ),
        )),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(
          toY: improved.toDouble(), color: AppColors.green.withOpacity(0.8),
          width: 44, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        )]),
        BarChartGroupData(x: 1, barRods: [BarChartRodData(
          toY: same.toDouble(), color: AppColors.blue.withOpacity(0.7),
          width: 44, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        )]),
        BarChartGroupData(x: 2, barRods: [BarChartRodData(
          toY: noAfter.toDouble(), color: AppColors.textMuted.withOpacity(0.35),
          width: 44, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        )]),
      ],
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final bool small;
  const _StatCard({required this.label, required this.value, required this.sub, this.small = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.label(size: 8, color: AppColors.textMuted, spacing: 0.5)),
        const SizedBox(height: 6),
        Text(value, style: AppText.sans(size: small ? 13 : 22, color: AppColors.purpleLight)),
        Text(sub, style: AppText.label(size: 8, color: AppColors.textMuted, spacing: 0)),
      ]),
    ),
  );
}