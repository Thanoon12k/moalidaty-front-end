import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme.dart';
import '../../receipts/controllers/receipt_controller.dart';
import '../../receipts/models/receipt.dart';
import '../models/subscriber.dart';

class SubscriberDetailScreen extends StatelessWidget {
  final Subscriber subscriber;
  const SubscriberDetailScreen({super.key, required this.subscriber});

  @override
  Widget build(BuildContext context) {
    final recCtrl = Get.find<ReceiptController>();
    final myReceipts = recCtrl.items
        .where((r) => r.subscriber == subscriber.id)
        .toList()
      ..sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        return b.month.compareTo(a.month);
      });

    final fmt = NumberFormat('#,##0', 'en');
    final totalPaid = myReceipts.fold(0.0, (s, r) => s + r.amountPaid);

    // QR data: encode subscriber ID for scanning
    final qrData =
        'moalidatna://sub/${subscriber.id}/gen/${subscriber.generator}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          subscriber.name,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'رمز QR للمشترك',
            onPressed: () => _showQrDialog(context, qrData),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Info card ──────────────────────────────────────────────────
          _InfoCard(subscriber: subscriber, totalPaid: totalPaid, fmt: fmt),
          const SizedBox(height: 16),

          // ── QR Code preview ────────────────────────────────────────────
          _QrCard(qrData: qrData, subscriber: subscriber),
          const SizedBox(height: 16),

          // ── Payment history chart ──────────────────────────────────────
          if (myReceipts.isNotEmpty) ...[
            _SectionTitle(title: 'سجل المدفوعات'),
            const SizedBox(height: 8),
            _PaymentChart(receipts: myReceipts, fmt: fmt),
            const SizedBox(height: 16),
            _SectionTitle(title: 'تفاصيل الإيصالات'),
            const SizedBox(height: 8),
            ...myReceipts.map((r) => _ReceiptTile(r: r)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'لا توجد إيصالات لهذا المشترك',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'رمز QR — ${subscriber.name}',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppTheme.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${subscriber.circuitNumber} — ${subscriber.ambers}A',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMid),
            ),
            const SizedBox(height: 4),
            Text(
              'امسح هذا الرمز لإنشاء إيصال سريع',
              style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, color: AppTheme.textMid),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Subscriber subscriber;
  final double totalPaid;
  final NumberFormat fmt;

  const _InfoCard({
    required this.subscriber,
    required this.totalPaid,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  subscriber.name.characters.first,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscriber.name,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'جوزة ${subscriber.circuitNumber}',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${subscriber.ambers}A',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoItem(Icons.phone, subscriber.phone.isEmpty ? '—' : subscriber.phone),
              _infoItem(Icons.calendar_today, subscriber.dateSubscribed.split('T').first),
              _infoItem(Icons.payments_rounded, '${fmt.format(totalPaid.toInt())} د.ع'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
              fontFamily: 'Cairo', color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

// ─── QR card ─────────────────────────────────────────────────────────────────

class _QrCard extends StatelessWidget {
  final String qrData;
  final Subscriber subscriber;
  const _QrCard({required this.qrData, required this.subscriber});

  void _showBig(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'رمز QR — ${subscriber.name}',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square, color: AppTheme.primary),
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1A1A2E)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${subscriber.circuitNumber} — ${subscriber.ambers}A',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMid),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showBig(context),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 90,
              eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square, color: AppTheme.primary),
              dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1A1A2E)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'رمز QR للمشترك',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                const Text(
                  'امسح الرمز لإنشاء إيصال سريع دون البحث اليدوي',
                  style: TextStyle(
                      fontFamily: 'Cairo', fontSize: 12, color: AppTheme.textMid),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _showBig(context),
                  icon: const Icon(Icons.zoom_in, size: 16),
                  label: const Text('تكبير',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─── Payment bar chart ────────────────────────────────────────────────────────

class _PaymentChart extends StatelessWidget {
  final List<Receipt> receipts;
  final NumberFormat fmt;
  const _PaymentChart({required this.receipts, required this.fmt});

  static const _months = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  @override
  Widget build(BuildContext context) {
    final sorted = List<Receipt>.from(receipts)
      ..sort((a, b) {
        if (a.year != b.year) return a.year.compareTo(b.year);
        return a.month.compareTo(b.month);
      });

    final bars = sorted.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.amountPaid,
            color: AppTheme.primary,
            width: 18,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
        ],
      ),
      child: BarChart(
        BarChartData(
          barGroups: bars,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _months[sorted[i].month],
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 9),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (v, _) => Text(
                  '${fmt.format(v ~/ 1000)}k',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}

// ─── Receipt tile ─────────────────────────────────────────────────────────────

class _ReceiptTile extends StatelessWidget {
  final Receipt r;
  const _ReceiptTile({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                if (r.workerName != null && r.workerName!.isNotEmpty)
                  Text(
                    'بواسطة: ${r.workerName}',
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppTheme.textMid),
                  ),
              ],
            ),
          ),
          Text(
            r.formattedAmount,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
