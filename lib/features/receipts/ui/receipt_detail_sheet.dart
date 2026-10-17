import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/receipt_controller.dart';
import '../models/receipt.dart';
import 'receipt_printer.dart';
import 'subscriber_qr.dart';

Future<void> showReceiptDetail(Receipt receipt) => showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ReceiptDetailSheet(receipt: receipt),
    );

class _ReceiptDetailSheet extends StatefulWidget {
  final Receipt receipt;
  const _ReceiptDetailSheet({required this.receipt});

  @override
  State<_ReceiptDetailSheet> createState() => _ReceiptDetailSheetState();
}

class _ReceiptDetailSheetState extends State<_ReceiptDetailSheet> {
  final _shot = ScreenshotController();
  final _auth = Get.find<AuthController>();
  String? _busy;

  Receipt get r => widget.receipt;
  String get _generatorName => _auth.profile.value?.generatorName ?? 'مولداتنا';

  Future<void> _run(String key, Future<void> Function() action) async {
    setState(() => _busy = key);
    try {
      await action();
    } catch (e) {
      showSnack('تعذرت العملية، حاول مرة أخرى', error: true);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _shareImage() async {
    final bytes = await _shot.capture(pixelRatio: 3);
    if (bytes == null) return;
    final name = 'receipt_${r.id}.png';
    final XFile file;
    if (kIsWeb) {
      file = XFile.fromData(bytes, name: name, mimeType: 'image/png');
    } else {
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/$name');
      await f.writeAsBytes(bytes);
      file = XFile(f.path, mimeType: 'image/png');
    }
    await SharePlus.instance.share(ShareParams(
      files: [file],
      text: 'إيصال ${r.subscriberName} — ${r.label} — $_generatorName',
    ));
  }

  Future<void> _delete() async {
    final ok = await confirmAction(
      title: 'حذف الإيصال',
      message: 'سيُحذف إيصال ${r.subscriberName} لشهر ${r.label} نهائياً. متابعة؟',
      confirm: 'حذف',
      destructive: true,
    );
    if (!ok) return;
    final done = await guard(() => Get.find<ReceiptController>().delete(r.id), success: 'تم حذف الإيصال');
    if (done && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (_, sc) => ListView(controller: sc, padding: const EdgeInsets.fromLTRB(18, 0, 18, 28), children: [
        Screenshot(
          controller: _shot,
          child: _ReceiptPaper(receipt: r, generatorName: _generatorName),
        ),
        const SizedBox(height: 18),
        Row(children: [
          _Action(
            icon: Icons.ios_share_rounded,
            label: 'مشاركة',
            color: p.primary,
            background: p.primarySoft,
            busy: _busy == 'share',
            onTap: () => _run('share', _shareImage),
          ),
          _Action(
            icon: Icons.print_rounded,
            label: 'طباعة',
            color: p.success,
            background: p.successSoft,
            busy: _busy == 'print',
            onTap: () => _run('print', () => ReceiptPrinter.printReceipt(r, _generatorName)),
          ),
          _Action(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            color: p.orange,
            background: p.orangeSoft,
            busy: _busy == 'pdf',
            onTap: () => _run('pdf', () => ReceiptPrinter.sharePdf(r, _generatorName)),
          ),
          if (_auth.isManager)
            _Action(
              icon: Icons.delete_outline_rounded,
              label: 'حذف',
              color: p.danger,
              background: p.dangerSoft,
              busy: false,
              onTap: _delete,
            ),
        ]),
      ]),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final bool busy;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: background,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: busy ? null : onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(children: [
                  busy
                      ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2, color: color))
                      : Icon(icon, color: color),
                  const SizedBox(height: 4),
                  Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ),
            ),
          ),
        ),
      );
}

/// The receipt as it is shared: always light "paper" whatever the app theme.
class _ReceiptPaper extends StatelessWidget {
  final Receipt receipt;
  final String generatorName;
  const _ReceiptPaper({required this.receipt, required this.generatorName});

  static const _ink = Color(0xFF181B2C);
  static const _muted = Color(0xFF656A80);
  static const _line = Color(0xFFE3E6EF);

  @override
  Widget build(BuildContext context) {
    final r = receipt;
    final gradient = AppPalette.light.heroGradient;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient, begin: Alignment.topRight, end: Alignment.bottomLeft),
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(generatorName,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                Text('إيصال دفع اشتراك', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ]),
            ),
            Text(r.number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Column(children: [
            _row('المشترك', r.subscriberName, strong: true),
            _row('رقم الجوزة', r.subscriberCircuit),
            if (r.subscriberPhone.isNotEmpty) _row('الهاتف', r.subscriberPhone),
            _row('الأمبيرات', '${r.subscriberAmbers} أمبير'),
            const _Dashes(),
            _row('الشهر', r.label, strong: true),
            _row('سعر الأمبير', r.formattedPrice),
          ]),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: const Color(0xFFE4F7EC), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF14A44D)),
            const SizedBox(width: 8),
            const Text('المبلغ المدفوع', style: TextStyle(color: _ink, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(r.formattedAmount,
                style: const TextStyle(color: Color(0xFF14A44D), fontWeight: FontWeight.w800, fontSize: 19)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(children: [
                _row('المحصّل', r.workerName ?? 'المدير'),
                _row('التاريخ', Fmt.dateTime(r.dateReceived)),
                if (r.notes.isNotEmpty) _row('ملاحظات', r.notes),
                const SizedBox(height: 6),
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('شكراً لاشتراككم 💡', style: TextStyle(color: _muted, fontSize: 12)),
                ),
              ]),
            ),
            const SizedBox(width: 14),
            QrImageView(
              data: subscriberQrData(r.subscriberId, r.generatorId),
              size: 74,
              padding: EdgeInsets.zero,
              eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: gradient[1]),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: _ink),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _row(String label, String value, {bool strong = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(color: _ink, fontSize: 14, fontWeight: strong ? FontWeight.w800 : FontWeight.w600)),
          ),
        ]),
      );
}

class _Dashes extends StatelessWidget {
  const _Dashes();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LayoutBuilder(
          builder: (_, c) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              (c.maxWidth / 9).floor(),
              (_) => Container(width: 5, height: 1.4, color: _ReceiptPaper._line),
            ),
          ),
        ),
      );
}
