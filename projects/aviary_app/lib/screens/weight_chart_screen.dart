import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/bird_service.dart';
import '../models/weight_record.dart';
import '../utils/error_helper.dart';

class WeightChartScreen extends StatefulWidget {
  final int birdId;
  final String birdName;
  const WeightChartScreen({super.key, required this.birdId, required this.birdName});

  @override
  State<WeightChartScreen> createState() => _WeightChartScreenState();
}

class _WeightChartScreenState extends State<WeightChartScreen> {
  final BirdService _birdService = BirdService();
  List<WeightRecord> _records = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final records = await _birdService.getWeights(widget.birdId);
      if (!mounted) return;
      setState(() { _records = records; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = '加载失败'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.birdName} 体重曲线')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _records.isEmpty
                  ? const Center(child: Text('暂无体重记录'))
                  : _buildChart(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    if (_records.length < 2) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('仅 ${_records.length} 条记录，需要至少 2 条绘制曲线',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            if (_records.length == 1)
              _weightRecordCard(_records.first),
          ],
        ),
      );
    }

    final sorted = List<WeightRecord>.from(_records)..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final minWeight = sorted.map((r) => r.weight).reduce(min) - 10;
    final maxWeight = sorted.map((r) => r.weight).reduce(max) + 10;

    // 生成时间戳
    final startTs = DateTime.parse(sorted.first.recordedAt).millisecondsSinceEpoch.toDouble();
    final endTs = DateTime.parse(sorted.last.recordedAt).millisecondsSinceEpoch.toDouble();
    final range = endTs - startTs;

    final fastingSpots = <FlSpot>[];
    final nonFastingSpots = <FlSpot>[];

    for (int i = 0; i < sorted.length; i++) {
      final r = sorted[i];
      final ts = DateTime.parse(r.recordedAt).millisecondsSinceEpoch.toDouble();
      final x = range > 0 ? (ts - startTs) / range : i.toDouble();
      if (r.isFasting) {
        fastingSpots.add(FlSpot(x, r.weight));
      } else {
        nonFastingSpots.add(FlSpot(x, r.weight));
      }
    }

    return Column(
      children: [
        // 图例
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(Colors.green, '空腹'),
              const SizedBox(width: 24),
              _legendDot(Colors.orange, '未空腹'),
              const SizedBox(width: 24),
              Text('记录数: ${sorted.length}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        // 图表
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 24, 16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxWeight - minWeight) / 5,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}g',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: range > 0 ? 1 : null,
                      getTitlesWidget: (value, meta) {
                        if (range <= 0) return const SizedBox();
                        final idx = (value * sorted.length).round();
                        if (idx >= 0 && idx < sorted.length) {
                          return Text(
                            sorted[idx].formattedDate.split(' ')[0],
                            style: const TextStyle(fontSize: 9),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: minWeight,
                maxY: maxWeight,
                lineBarsData: [
                  if (fastingSpots.length >= 2)
                    LineChartBarData(
                      spots: fastingSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: Colors.green,
                            strokeWidth: 0,
                          ),
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  if (nonFastingSpots.length >= 2)
                    LineChartBarData(
                      spots: nonFastingSpots,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      dashArray: [6, 3],
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: Colors.orange,
                            strokeWidth: 0,
                          ),
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                      final barIndex = spot.barIndex;
                      final lineName = barIndex == 0 ? '空腹' : '未空腹';
                      return LineTooltipItem(
                        '$lineName: ${spot.y.toStringAsFixed(1)}g',
                        TextStyle(
                          color: barIndex == 0 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        // 最近记录列表
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('最近记录', style: Theme.of(context).textTheme.titleSmall),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sorted.length > 10 ? 10 : sorted.length,
                  itemBuilder: (context, index) {
                    final i = sorted.length - 1 - index;
                    return _weightRecordCard(sorted[i]);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weightRecordCard(WeightRecord r) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: r.isFasting ? Colors.green[100] : Colors.orange[100],
        child: Text(r.isFasting ? '空腹' : '未空', style: const TextStyle(fontSize: 10)),
      ),
      title: Text('${r.weight.toStringAsFixed(1)} g'),
      subtitle: Text(r.formattedDate),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    final weightCtrl = TextEditingController();
    final isFasting = ValueNotifier<bool>(true);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('记录体重'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '体重 (g)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: isFasting,
              builder: (context, v, _) => Row(
                children: [
                  const Text('空腹状态: '),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('空腹'), selected: v, onSelected: (_) => isFasting.value = true),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('未空腹'), selected: !v, onSelected: (_) => isFasting.value = false),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final w = double.tryParse(weightCtrl.text);
              if (w == null || w <= 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('请输入有效体重')),
                );
                return;
              }
              try {
                await _birdService.addWeight(
                  widget.birdId, w,
                  isFasting: isFasting.value,
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _load();
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(friendlyError(e))),
                );
              }
            },
            child: const Text('记录'),
          ),
        ],
      ),
    );
  }
}
