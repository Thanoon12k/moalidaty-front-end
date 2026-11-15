import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../analytics/analytics.dart';
import '../theme/app_palette.dart';
import '../utils/format.dart';

const _font = 'Cairo';

FlLine _hairline(Color c) => FlLine(color: c, strokeWidth: 1); // solid, never dashed

double _niceMax(double v) {
  if (v <= 0) return 1;
  final mag = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
  for (final m in [1.0, 1.2, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 6.0, 8.0, 10.0]) {
    if (v <= m * mag) return m * mag;
  }
  return 10 * mag;
}

// ─── Hero line (white on the blue balance card) ──────────────────────────────

/// Smooth white line with a soft fill and a pinned tooltip on the latest
/// point (as in the reference balance card); the tooltip follows the finger.
class HeroLineChart extends StatefulWidget {
  final List<double> values;
  final String Function(int index) labelAt;
  final Color accent;

  const HeroLineChart({super.key, required this.values, required this.labelAt, required this.accent});

  @override
  State<HeroLineChart> createState() => _HeroLineChartState();
}

class _HeroLineChartState extends State<HeroLineChart> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final values = widget.values;
    if (values.length < 2) return const SizedBox.shrink();
    final spots = [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])];
    final maxY = values.reduce(math.max);
    final shown = spots[(_touched ?? spots.length - 1).clamp(0, spots.length - 1)];
    final accent = widget.accent;
    final bar = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      preventCurveOverShooting: true,
      color: Colors.white,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.32), Colors.white.withValues(alpha: 0)],
        ),
      ),
    );
    return Semantics(
      label: 'منحنى التحصيل، آخر قيمة ${Fmt.money(values.last)}',
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: 0,
          maxY: maxY <= 0 ? 1 : maxY * 1.45,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineBarsData: [bar],
          showingTooltipIndicators: [
            ShowingTooltipIndicators([LineBarSpot(bar, 0, shown)]),
          ],
          lineTouchData: LineTouchData(
            // Built-in touches would hide the pinned tooltip; track it here.
            handleBuiltInTouches: false,
            touchCallback: (event, response) {
              final spot = response?.lineBarSpots?.firstOrNull;
              final ended = event is FlTapUpEvent || event is FlPanEndEvent || event is FlLongPressEnd ||
                  event is FlPointerExitEvent;
              final next = ended || spot == null ? null : spot.spotIndex;
              if (next != _touched) setState(() => _touched = next);
            },
            getTouchedSpotIndicator: (_, idx) => idx
                .map((_) => TouchedSpotIndicatorData(
                      FlLine(color: Colors.white.withValues(alpha: 0.45), strokeWidth: 1),
                      FlDotData(
                        getDotPainter: (_, _, _, _) =>
                            FlDotCirclePainter(radius: 5, color: Colors.white, strokeWidth: 3, strokeColor: accent),
                      ),
                    ))
                .toList(),
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.white,
              tooltipBorderRadius: BorderRadius.circular(8),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tooltipMargin: 10,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${widget.labelAt(s.x.toInt())}\n',
                        const TextStyle(fontFamily: _font, fontSize: 9.5, color: Color(0xFF656A80), height: 1.3),
                        children: [
                          TextSpan(
                            text: Fmt.compactMoney(s.y),
                            style: const TextStyle(
                                fontFamily: _font, fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF181B2C)),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Trend: collected vs expected per month ─────────────────────────────────

class TrendChart extends StatelessWidget {
  final List<MonthSummary> data;
  const TrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (data.isEmpty) return const SizedBox.shrink();
    final maxV = data.map((d) => math.max(d.collected, d.expected)).reduce(math.max);
    final maxY = _niceMax(maxV * 1.08);
    final step = math.max(1, (data.length / 6).ceil());
    LineChartBarData line(List<double> ys, Color c, {bool fill = false, double width = 2.5}) => LineChartBarData(
          spots: [for (var i = 0; i < ys.length; i++) FlSpot(i.toDouble(), ys[i])],
          isCurved: true,
          curveSmoothness: 0.25,
          preventCurveOverShooting: true,
          color: c,
          barWidth: width,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: data.length <= 12,
            getDotPainter: (_, _, _, _) =>
                FlDotCirclePainter(radius: 3.5, color: c, strokeWidth: 2, strokeColor: p.surface),
          ),
          belowBarData: BarAreaData(
            show: fill,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.withValues(alpha: 0.22), c.withValues(alpha: 0.0)],
            ),
          ),
        );

    return Semantics(
      label: 'منحنى التحصيل الشهري مقارنة بالمتوقع',
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: math.max(1, data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => _hairline(p.grid),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 4,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(Fmt.axis(v), style: TextStyle(fontFamily: _font, fontSize: 10, color: p.textMuted)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length || i % step != 0 && i != data.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(data[i].key.shortLabel,
                        style: TextStyle(fontFamily: _font, fontSize: 10, color: p.textMuted)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            line(data.map((d) => d.expected).toList(), p.textMuted, width: 1.6),
            line(data.map((d) => d.collected).toList(), p.series[0], fill: true),
          ],
          lineTouchData: LineTouchData(
            getTouchedSpotIndicator: (_, idx) => idx
                .map((_) => TouchedSpotIndicatorData(_hairline(p.border), const FlDotData()))
                .toList(),
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => p.surfaceAlt,
              tooltipBorderRadius: BorderRadius.circular(10),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) => spots.map((s) {
                final d = data[s.x.toInt()];
                final isCollected = s.barIndex == 1;
                return LineTooltipItem(
                  isCollected ? '${d.key.label}\n' : '',
                  TextStyle(fontFamily: _font, fontSize: 10.5, color: p.textSecondary),
                  children: [
                    TextSpan(
                      text: '${isCollected ? 'المحصّل' : 'المتوقع'}: ${Fmt.compactMoney(s.y)}',
                      style: TextStyle(
                          fontFamily: _font, fontSize: 11.5, fontWeight: FontWeight.w700, color: p.textPrimary),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Donut ──────────────────────────────────────────────────────────────────

class DonutSlice {
  final String label;
  final double value;
  final Color color;
  final String valueLabel;
  const DonutSlice(this.label, this.value, this.color, this.valueLabel);
}

class DonutChart extends StatefulWidget {
  final List<DonutSlice> slices;
  final Widget center;
  final double size;
  final double thickness;

  const DonutChart({super.key, required this.slices, required this.center, this.size = 190, this.thickness = 18});

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final slices = widget.slices.where((s) => s.value > 0).toList();
    final total = slices.fold(0.0, (a, s) => a + s.value);
    final touched = _touched >= 0 && _touched < slices.length ? slices[_touched] : null;
    return Semantics(
      label: slices.map((s) => '${s.label}: ${s.valueLabel}').join('، '),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(alignment: Alignment.center, children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2,
              centerSpaceRadius: widget.size / 2 - widget.thickness - 6,
              pieTouchData: PieTouchData(
                touchCallback: (event, res) {
                  if (!event.isInterestedForInteractions) return;
                  setState(() => _touched = res?.touchedSection?.touchedSectionIndex ?? -1);
                },
              ),
              sections: total <= 0
                  ? [PieChartSectionData(value: 1, color: p.surfaceAlt, radius: widget.thickness, showTitle: false)]
                  : [
                      for (var i = 0; i < slices.length; i++)
                        PieChartSectionData(
                          value: slices[i].value,
                          color: slices[i].color,
                          radius: i == _touched ? widget.thickness + 5 : widget.thickness,
                          showTitle: false,
                        ),
                    ],
            ),
          ),
          if (touched != null)
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(touched.valueLabel,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: p.textPrimary)),
              Text(touched.label, style: TextStyle(fontSize: 11.5, color: p.textSecondary)),
            ])
          else
            widget.center,
        ]),
      ),
    );
  }
}

/// Legend chips under a donut (identity never by color alone).
class ChartLegend extends StatelessWidget {
  final List<(String, Color)> items;
  final WrapAlignment alignment;
  const ChartLegend({super.key, required this.items, this.alignment = WrapAlignment.center});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      alignment: alignment,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (label, color) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.border),
              color: p.surface,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 11.5, color: p.textPrimary, fontWeight: FontWeight.w600)),
            ]),
          ),
      ],
    );
  }
}

// ─── Semicircle gauge ───────────────────────────────────────────────────────

class SemiGauge extends StatelessWidget {
  final double value; // 0..1
  final Widget center;
  final double width;

  const SemiGauge({super.key, required this.value, required this.center, this.width = 230});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final v = value.clamp(0.0, 1.0);
    final color = v >= 0.8 ? p.success : (v >= 0.5 ? p.warning : p.danger);
    return Semantics(
      label: 'نسبة التحصيل ${(v * 100).round()}%',
      child: SizedBox(
        width: width,
        height: width / 2 + 34,
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Positioned.fill(
            bottom: 34,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: v),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, t, _) => CustomPaint(painter: _GaugePainter(t, p.surfaceAlt, color)),
            ),
          ),
          Positioned(bottom: 26, child: center),
          Positioned(
            bottom: 0,
            left: 6,
            right: 6,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('100%', style: TextStyle(fontSize: 10.5, color: p.textMuted)),
              Text('0%', style: TextStyle(fontSize: 10.5, color: p.textMuted)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color track;
  final Color color;
  _GaugePainter(this.value, this.track, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final r = math.min(size.width / 2, size.height) - stroke / 2;
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: r);
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, base);
    if (value > 0) {
      // Fills from the right (RTL start) towards the left.
      canvas.drawArc(rect, 0, -math.pi * value, false, base..color = color);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value || old.color != color || old.track != track;
}

// ─── Paid vs unpaid per month (stacked) ─────────────────────────────────────

class PaidUnpaidBars extends StatelessWidget {
  final List<MonthSummary> data;
  const PaidUnpaidBars({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (data.isEmpty) return const SizedBox.shrink();
    final maxY = _niceMax(data.map((d) => d.dueCount.toDouble()).fold(0.0, math.max));
    // 1px surface edge on each segment → a 2px gap between stacked segments.
    final gap = BorderSide(color: p.surface, width: 1);
    final width = math.min(22.0, 220 / data.length);
    return Semantics(
      label: 'عدد الدافعين وغير الدافعين لكل شهر',
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => _hairline(p.grid),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxY / 4,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(v.round().toString(),
                      style: TextStyle(fontFamily: _font, fontSize: 10, color: p.textMuted)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(data[i].key.shortLabel,
                        style: TextStyle(fontFamily: _font, fontSize: 9.5, color: p.textMuted)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => p.surfaceAlt,
              tooltipBorderRadius: BorderRadius.circular(10),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, _, _, _) {
                final d = data[group.x];
                return BarTooltipItem(
                  '${d.key.label}\n',
                  TextStyle(fontFamily: _font, fontSize: 10.5, color: p.textSecondary),
                  children: [
                    TextSpan(
                      text: 'دفع ${d.paidCount} • لم يدفع ${d.unpaidCount}',
                      style: TextStyle(
                          fontFamily: _font, fontSize: 11.5, fontWeight: FontWeight.w700, color: p.textPrimary),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: data[i].dueCount.toDouble(),
                  width: width,
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  rodStackItems: [
                    BarChartRodStackItem(0, data[i].paidCount.toDouble(), p.success, borderSide: gap),
                    if (data[i].unpaidCount > 0)
                      BarChartRodStackItem(data[i].paidCount.toDouble(), data[i].dueCount.toDouble(), p.danger,
                          borderSide: gap),
                  ],
                ),
              ]),
          ],
        ),
      ),
    );
  }
}

// ─── Monthly payments of one subscriber ─────────────────────────────────────

class SubscriberHistoryChart extends StatelessWidget {
  /// One entry per budget month, oldest first; null amount = not paid.
  final List<(MonthKey, double?)> months;
  const SubscriberHistoryChart({super.key, required this.months});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (months.isEmpty) return const SizedBox.shrink();
    final maxPaid = months.map((m) => m.$2 ?? 0).fold(0.0, math.max);
    final maxY = _niceMax(maxPaid * 1.1);
    final width = math.min(20.0, 240 / months.length);
    return Semantics(
      label: 'مدفوعات المشترك لكل شهر',
      child: BarChart(
        BarChartData(
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (_) => _hairline(p.grid),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: maxY / 3,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(Fmt.axis(v), style: TextStyle(fontFamily: _font, fontSize: 9.5, color: p.textMuted)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= months.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(months[i].$1.shortLabel,
                        style: TextStyle(fontFamily: _font, fontSize: 9, color: p.textMuted)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => p.surfaceAlt,
              tooltipBorderRadius: BorderRadius.circular(10),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, _, _, _) {
                final (key, paid) = months[group.x];
                return BarTooltipItem(
                  '${key.label}\n',
                  TextStyle(fontFamily: _font, fontSize: 10.5, color: p.textSecondary),
                  children: [
                    TextSpan(
                      text: paid == null ? 'لم يدفع' : Fmt.money(paid),
                      style: TextStyle(
                          fontFamily: _font,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: paid == null ? p.danger : p.textPrimary),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < months.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  // Unpaid months show a short red stub so they stay visible.
                  toY: months[i].$2 ?? maxY * 0.06,
                  width: width,
                  color: months[i].$2 == null ? p.danger : p.series[0],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}

// ─── Sparkline (mini cards) ─────────────────────────────────────────────────

class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  const Sparkline({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox.shrink();
    final maxY = values.reduce(math.max);
    return ExcludeSemantics(
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY <= 0 ? 1 : maxY * 1.15,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
              isCurved: true,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
