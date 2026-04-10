import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/theme.dart';
import '../controllers/receipt_controller.dart';
import '../models/receipt.dart';

class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReceiptController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: ctrl.items.isEmpty
            ? _EmptyState(onAdd: () => ctrl.showAddSheet(context))
            : RefreshIndicator(
                onRefresh: ctrl.load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ReceiptCard(
                    receipt: ctrl.items[i],
                    onTap: () => _openReceiptDetail(context, ctrl.items[i]),
                  ),
                ),
              ),
      );
    });
  }

  void _openReceiptDetail(BuildContext context, Receipt receipt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReceiptDetailSheet(receipt: receipt),
    );
  }
}

// ─── Receipt list card ────────────────────────────────────────────────────────

class _ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;

  const _ReceiptCard({required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Icon
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long, color: AppTheme.accent),
            ),
            const SizedBox(width: 14),
            // Main info
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(receipt.subscriberName,
                    style: const TextStyle(fontFamily:'Cairo',
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(receipt.label,
                    style: const TextStyle(fontFamily:'Cairo',
                        color: AppTheme.textMid, fontSize: 13)),
                if (receipt.workerName != null)
                  Text('العامل: ${receipt.workerName}',
                      style: const TextStyle(fontFamily:'Cairo',
                          color: AppTheme.textLight, fontSize: 12)),
              ],
            )),
            // Amount
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(receipt.formattedAmount,
                  style: const TextStyle(fontFamily:'Cairo',
                      fontWeight: FontWeight.w700, color: AppTheme.accent,
                      fontSize: 15)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal:6, vertical:2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryL,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${receipt.subscriberAmbers} أمبير',
                    style: const TextStyle(fontFamily:'Cairo',
                        color: AppTheme.primary, fontSize: 11)),
              ),
            ]),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_left, color: AppTheme.textLight),
          ]),
        ),
      ),
    );
  }
}

// ─── Receipt detail bottom sheet with image generator ─────────────────────────

class _ReceiptDetailSheet extends StatelessWidget {
  final Receipt receipt;
  final ScreenshotController _screenshotCtrl = ScreenshotController();

  _ReceiptDetailSheet({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.6,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(controller: sc, children: [
          // Drag handle
          Center(child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          )),

          // ── The receipt widget (captured by Screenshot) ────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Screenshot(
              controller: _screenshotCtrl,
              child: _ReceiptCard2(receipt: receipt),
            ),
          ),

          const SizedBox(height: 20),

          // ── Action buttons ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: _ActionButton(
                icon: Icons.share,
                label: 'مشاركة',
                color: AppTheme.primary,
                onPressed: () => Get.find<ReceiptController>().shareReceiptImage(
                  context, _screenshotCtrl,
                  'receipt_${receipt.id}_${receipt.label}',
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(
                icon: Icons.print,
                label: 'طباعة',
                color: AppTheme.accent,
                onPressed: () => Get.find<ReceiptController>().printReceipt(receipt),
              )),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(
                icon: Icons.download,
                label: 'حفظ',
                color: AppTheme.warning,
                onPressed: () async {
                  final ctrl = Get.find<ReceiptController>();
                  await ctrl.shareReceiptImage(
                    context, _screenshotCtrl,
                    'receipt_${receipt.id}',
                  );
                },
              )),
            ]),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ─── The styled receipt card (what gets captured as image) ───────────────────

class _ReceiptCard2 extends StatelessWidget {
  final Receipt receipt;
  const _ReceiptCard2({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header
        Container(
          color: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(children: [
            const Icon(Icons.electrical_services_rounded,
                color: Colors.white, size: 36),
            const SizedBox(height: 8),
            const Text('إيصال دفع اشتراك',
                style: TextStyle(fontFamily:'Cairo', color:Colors.white,
                    fontSize:20, fontWeight:FontWeight.w700)),
            const SizedBox(height: 4),
            Text('#${receipt.id.toString().padLeft(5,'0')}',
                style: TextStyle(fontFamily:'Cairo',
                    color:Colors.white.withOpacity(0.8), fontSize:13)),
          ]),
        ),

        // Body rows
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(children: [
            _row('المشترك', receipt.subscriberName, bold: true),
            _row('رقم الجوزة', receipt.subscriberCircuit),
            _row('رقم الهاتف', receipt.subscriberPhone.isEmpty ? '—' : receipt.subscriberPhone),
            _row('الأمبيرات', '${receipt.subscriberAmbers} أمبير'),
            const Divider(height: 24),
            _row('الشهر / السنة', '${receipt.monthName}  ${receipt.year}'),
            _row('سعر الأمبير', receipt.formattedPrice),
            const Divider(height: 24),
          ]),
        ),

        // Total — green band
        Container(
          color: AppTheme.accent,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المبلغ المدفوع',
                  style: TextStyle(fontFamily:'Cairo', color:Colors.white,
                      fontWeight:FontWeight.w700, fontSize:16)),
              Text(receipt.formattedAmount,
                  style: const TextStyle(fontFamily:'Cairo', color:Colors.white,
                      fontWeight:FontWeight.w700, fontSize:20)),
            ],
          ),
        ),

        // Footer meta
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(children: [
            if (receipt.workerName != null) _row('العامل', receipt.workerName!),
            _row('تاريخ الدفع', _formatDate(receipt.dateReceived)),
            if (receipt.notes.isNotEmpty) _row('ملاحظات', receipt.notes),
          ]),
        ),

        // Receipt footer
        Container(
          color: AppTheme.primary,
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: const Text('شكراً لاشتراككم — مولداتنا',
              style: TextStyle(fontFamily:'Cairo', color:Colors.white,
                  fontWeight:FontWeight.w600),
              textAlign: TextAlign.center),
        ),
      ]),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontFamily:'Cairo',
                  color: AppTheme.textMid, fontSize: 13)),
          Text(value,
              style: TextStyle(fontFamily:'Cairo',
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: AppTheme.textDark, fontSize: 14)),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}/${dt.month.toString().padLeft(2,'0')}/${dt.day.toString().padLeft(2,'0')}  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) {
      return iso;
    }
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily:'Cairo',
            color: Colors.white, fontSize: 12)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.receipt_long_outlined, size:80, color: AppTheme.textLight),
      const SizedBox(height: 16),
      const Text('لا توجد إيصالات بعد',
          style: TextStyle(fontFamily:'Cairo', fontSize:18,
              fontWeight: FontWeight.w600, color: AppTheme.textMid)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('إضافة إيصال'),
      ),
    ]),
  );
}
