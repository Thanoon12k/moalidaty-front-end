import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/widgets/feedback.dart';
import '../../auth/controllers/auth_controller.dart';
import 'subscriber_qr.dart';

/// Opens the camera and returns the scanned subscriber id (or null).
Future<int?> scanSubscriberQr() async {
  final supported = kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
  if (!supported) {
    showSnack('مسح رمز QR غير مدعوم على هذا الجهاز', error: true);
    return null;
  }
  return Get.to<int>(() => const QrScannerScreen(), transition: Transition.downToUp);
}

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    final parsed = parseSubscriberQr(raw);
    final myGenerator = Get.find<AuthController>().profile.value?.generatorId;
    if (parsed == null) {
      setState(() => _error = 'رمز QR غير صالح');
      return;
    }
    if (parsed.$2 != myGenerator) {
      setState(() => _error = 'هذا الرمز لمشترك في مولدة أخرى');
      return;
    }
    _done = true;
    _ctrl.stop();
    Get.back(result: parsed.$1);
  }

  @override
  Widget build(BuildContext context) {
    const frame = 260.0;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('مسح رمز المشترك', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'الإضاءة',
            icon: const Icon(Icons.flashlight_on_rounded),
            onPressed: _ctrl.toggleTorch,
          ),
        ],
      ),
      body: Stack(children: [
        MobileScanner(
          controller: _ctrl,
          onDetect: _onDetect,
          errorBuilder: (context, error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                error.errorCode == MobileScannerErrorCode.permissionDenied
                    ? 'يجب السماح للتطبيق باستخدام الكاميرا'
                    : 'تعذر تشغيل الكاميرا',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        // Dim everything but the scan window.
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.55), BlendMode.srcOut),
          child: Stack(children: [
            Container(decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut)),
            Center(
              child: Container(
                width: frame,
                height: frame,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ]),
        ),
        Center(
          child: SizedBox(width: frame, height: frame, child: CustomPaint(painter: _CornerPainter())),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 64,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: (_error == null ? Colors.black : Colors.red.shade700).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _error ?? 'وجّه الكاميرا نحو رمز QR الخاص بالمشترك',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 30.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;
    for (final pts in [
      const [Offset(0, len), Offset.zero, Offset(len, 0)],
      [Offset(w - len, 0), Offset(w, 0), Offset(w, len)],
      [Offset(0, h - len), Offset(0, h), Offset(len, h)],
      [Offset(w - len, h), Offset(w, h), Offset(w, h - len)],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(pts[0].dx, pts[0].dy)
          ..lineTo(pts[1].dx, pts[1].dy)
          ..lineTo(pts[2].dx, pts[2].dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
