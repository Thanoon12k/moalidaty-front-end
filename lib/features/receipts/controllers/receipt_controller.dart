import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/network/api_client.dart';
import '../../../core/theme.dart';
import '../models/receipt.dart';
import '../../subscribers/controllers/subscriber_controller.dart';
import '../../budgets/controllers/budget_controller.dart';
import '../../workers/controllers/worker_controller.dart';
import '../ui/qr_scanner_screen.dart';

class ReceiptController extends GetxController {
  final _dio = Get.find<ApiClient>().dio;

  final items     = <Receipt>[].obs;
  final isLoading = false.obs;
  final errorMsg  = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final res = await _dio.get('/receipts/');
      items.value = (res.data as List)
          .map((j) => Receipt.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      errorMsg.value = _err(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> add(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/receipts/', data: data);
      items.insert(0, Receipt.fromJson(res.data as Map<String, dynamic>));
      return true;
    } on DioException catch (e) {
      errorMsg.value = _err(e);
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/receipts/$id/');
      items.removeWhere((r) => r.id == id);
      return true;
    } on DioException catch (e) {
      errorMsg.value = _err(e);
      return false;
    }
  }

  String _err(DioException e) {
    final d = e.response?.data;
    if (d is Map && d.containsKey('detail')) return d['detail'];
    return 'حدث خطأ';
  }

  void showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddReceiptSheet(),
    );
  }

  // ── Receipt image sharing ──────────────────────────────────────────────────

  /// Captures the receipt widget and shares it as PNG image
  Future<void> shareReceiptImage(
    BuildContext context,
    ScreenshotController screenshotCtrl,
    String filename,
  ) async {
    try {
      final bytes = await screenshotCtrl.capture(pixelRatio: 3.0);
      if (bytes == null) return;

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'إيصال دفع — مولداتنا',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل المشاركة: $e')),
      );
    }
  }

  /// Prints the receipt using the pdf+printing packages
  Future<void> printReceipt(Receipt receipt) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      textDirection: pw.TextDirection.rtl,
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text('إيصال دفع — ${receipt.subscriberName}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          _pdfRow('المشترك', receipt.subscriberName),
          _pdfRow('رقم الجوزة', receipt.subscriberCircuit),
          _pdfRow('الشهر / السنة', '${receipt.monthName} ${receipt.year}'),
          _pdfRow('الأمبيرات', '${receipt.subscriberAmbers} أمبير'),
          _pdfRow('سعر الأمبير', receipt.formattedPrice),
          pw.Divider(),
          _pdfRow('المبلغ المدفوع', receipt.formattedAmount,
              bold: true, fontSize: 18),
          pw.SizedBox(height: 8),
          if (receipt.workerName != null) _pdfRow('العامل', receipt.workerName!),
          pw.SizedBox(height: 16),
          pw.Text('رقم الإيصال: #${receipt.id.toString().padLeft(5, '0')}',
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    ));
    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
    );
  }

  pw.Widget _pdfRow(String label, String value,
      {bool bold = false, double fontSize = 13}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              )),
          pw.Text(value,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              )),
        ],
      ),
    );
  }
}

// ─── Add receipt bottom sheet ──────────────────────────────────────────────────

class _AddReceiptSheet extends StatefulWidget {
  const _AddReceiptSheet();
  @override
  State<_AddReceiptSheet> createState() => _AddReceiptSheetState();
}

class _AddReceiptSheetState extends State<_AddReceiptSheet> {
  final _ctrl    = Get.find<ReceiptController>();
  final _subCtrl = Get.find<SubscriberController>();
  final _budCtrl = Get.find<BudgetController>();
  final _worCtrl = Get.find<WorkerController>();

  int? _selectedSubscriberId;
  int? _selectedBudgetId;
  int? _selectedWorkerId;
  bool _loading = false;

  double get _amberPrice {
    if (_selectedBudgetId == null) return 0;
    try {
      return _budCtrl.items.firstWhere((b) => b.id == _selectedBudgetId).amberPrice;
    } catch (_) { return 0; }
  }

  int get _ambers {
    if (_selectedSubscriberId == null) return 0;
    try {
      return _subCtrl.items.firstWhere((s) => s.id == _selectedSubscriberId).ambers;
    } catch (_) { return 0; }
  }

  double get _total => _amberPrice * _ambers;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(controller: sc, children: [
            const Text('إضافة إيصال جديد',
                style: TextStyle(fontFamily:'Cairo',fontSize:20,fontWeight:FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),

            // ── QR scan shortcut ───────────────────────────────────
            OutlinedButton.icon(
              onPressed: () async {
                final subId = await Get.to<int>(
                  () => const QrScannerScreen(),
                  transition: Transition.downToUp,
                );
                if (subId != null && mounted) {
                  setState(() => _selectedSubscriberId = subId);
                }
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('مسح QR لاختيار المشترك',
                  style: TextStyle(fontFamily: 'Cairo')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Row(children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('أو اختر يدوياً',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppTheme.textMid,
                        fontSize: 12)),
              ),
              Expanded(child: Divider()),
            ]),
            const SizedBox(height: 12),

            // Subscriber dropdown
            Obx(() => DropdownButtonFormField<int>(
              value: _selectedSubscriberId,
              decoration: const InputDecoration(labelText: 'اختر المشترك *'),
              items: _subCtrl.items.map((s) =>
                  DropdownMenuItem(value: s.id, child: Text(s.name,
                      style: const TextStyle(fontFamily:'Cairo')))).toList(),
              onChanged: (v) => setState(() => _selectedSubscriberId = v),
            )),
            const SizedBox(height: 12),

            // Budget dropdown
            Obx(() => DropdownButtonFormField<int>(
              value: _selectedBudgetId,
              decoration: const InputDecoration(labelText: 'اختر الشهر *'),
              items: _budCtrl.items.map((b) =>
                  DropdownMenuItem(value: b.id, child: Text(b.label,
                      style: const TextStyle(fontFamily:'Cairo')))).toList(),
              onChanged: (v) => setState(() => _selectedBudgetId = v),
            )),
            const SizedBox(height: 12),

            // Worker dropdown (optional)
            Obx(() => DropdownButtonFormField<int>(
              value: _selectedWorkerId,
              decoration: const InputDecoration(labelText: 'العامل (اختياري)'),
              items: [
                const DropdownMenuItem(value: null,
                    child: Text('بدون عامل', style: TextStyle(fontFamily:'Cairo'))),
                ..._worCtrl.items.map((w) =>
                    DropdownMenuItem(value: w.id, child: Text(w.name,
                        style: const TextStyle(fontFamily:'Cairo')))),
              ],
              onChanged: (v) => setState(() => _selectedWorkerId = v),
            )),
            const SizedBox(height: 20),

            // Summary card
            if (_selectedSubscriberId != null && _selectedBudgetId != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  _summaryRow('الأمبيرات', '$_ambers أمبير'),
                  _summaryRow('سعر الأمبير', '${_amberPrice.toStringAsFixed(0)} د.ع'),
                  const Divider(),
                  _summaryRow('المبلغ الكلي', '${_total.toStringAsFixed(0)} د.ع',
                      bold: true),
                ]),
              ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: (_loading || _selectedSubscriberId == null || _selectedBudgetId == null)
                  ? null
                  : () async {
                      final budget = _budCtrl.items
                          .firstWhere((b) => b.id == _selectedBudgetId!);
                      setState(() => _loading = true);
                      final ok = await _ctrl.add({
                        'subscriber':  _selectedSubscriberId,
                        'worker':      _selectedWorkerId,
                        'year':        budget.year,
                        'month':       budget.month,
                        'amber_price': _amberPrice,
                        'amount_paid': _total,
                      });
                      setState(() => _loading = false);
                      if (ok && mounted) Navigator.pop(context);
                    },
              child: _loading
                  ? const SizedBox(width:20,height:20,
                      child: CircularProgressIndicator(color:Colors.white,strokeWidth:2))
                  : const Text('تسجيل الإيصال'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily:'Cairo',
              color: const Color(0xFF5A5A64),
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
          Text(value, style: TextStyle(fontFamily:'Cairo',
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              color: bold ? const Color(0xFF164EA0) : const Color(0xFF14141E),
              fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }
}
