import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme.dart';

/// Scans a subscriber QR code and returns the subscriber ID as int.
/// QR format: moalidatna://sub/[id]/gen/[genId]
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    // Expected: moalidatna://sub/3/gen/7
    final uri = Uri.tryParse(raw);
    if (uri == null ||
        uri.scheme != 'moalidatna' ||
        uri.host != 'sub') {
      _showError('رمز QR غير صالح');
      return;
    }

    final parts = raw.split('/');
    // parts: ['moalidatna:', '', 'sub', '<id>', 'gen', '<genId>']
    final subId = int.tryParse(parts.length > 3 ? parts[3] : '');
    if (subId == null) {
      _showError('تعذر قراءة رمز المشترك');
      return;
    }

    setState(() => _scanned = true);
    _ctrl.stop();
    Get.back(result: subId);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _scanned = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'مسح رمز QR المشترك',
          style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _ctrl.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Camera feed ─────────────────────────────────────────────────
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),

          // ── Scan frame overlay ──────────────────────────────────────────
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // ── Corner decorations ──────────────────────────────────────────
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: CustomPaint(painter: _CornerPainter()),
            ),
          ),

          // ── Instruction text ────────────────────────────────────────────
          Positioned(
            bottom: 80,
            left: 0, right: 0,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'وجّه الكاميرا نحو رمز QR الخاص بالمشترك',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                if (_scanned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'تم المسح بنجاح!',
                          style: TextStyle(
                              fontFamily: 'Cairo', color: Colors.white),
                        ),
                      ],
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

/// Draws thick corner markers on the scan frame
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 28.0;
    const thickness = 4.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      // top-left
      [Offset(0, len), Offset.zero, Offset(len, 0)],
      // top-right
      [Offset(size.width - len, 0), Offset(size.width, 0), Offset(size.width, len)],
      // bottom-left
      [Offset(0, size.height - len), Offset(0, size.height), Offset(len, size.height)],
      // bottom-right
      [
        Offset(size.width - len, size.height),
        Offset(size.width, size.height),
        Offset(size.width, size.height - len),
      ],
    ];

    for (final c in corners) {
      final path = Path()
        ..moveTo(c[0].dx, c[0].dy)
        ..lineTo(c[1].dx, c[1].dy)
        ..lineTo(c[2].dx, c[2].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
