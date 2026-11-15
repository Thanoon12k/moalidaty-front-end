import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/format.dart';
import '../models/receipt.dart';
import 'subscriber_qr.dart';

/// Builds the receipt as a PDF. The old version used the default PDF font,
/// which has no Arabic glyphs — every label printed as empty boxes.
class ReceiptPrinter {
  static pw.ThemeData? _theme;

  static Future<pw.ThemeData> _arabicTheme() async {
    if (_theme != null) return _theme!;
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    return _theme = pw.ThemeData.withFont(base: regular, bold: bold);
  }

  static Future<Uint8List> build(Receipt r, String generatorName, PdfPageFormat format) async {
    final theme = await _arabicTheme();
    final narrow = format.width < 100 * PdfPageFormat.mm; // thermal roll
    final doc = pw.Document(title: 'إيصال ${r.number}', theme: theme);
    const blue = PdfColor.fromInt(0xFF1F55D6);
    const grey = PdfColor.fromInt(0xFF656A80);

    pw.Widget row(String label, String value, {bool strong = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text(label, style: pw.TextStyle(color: grey, fontSize: narrow ? 9 : 11)),
            pw.Text(value,
                style: pw.TextStyle(
                  fontSize: strong ? (narrow ? 12 : 15) : (narrow ? 9.5 : 11.5),
                  fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
                )),
          ]),
        );

    doc.addPage(pw.Page(
      pageFormat: format.copyWith(
        marginLeft: narrow ? 4 * PdfPageFormat.mm : 14 * PdfPageFormat.mm,
        marginRight: narrow ? 4 * PdfPageFormat.mm : 14 * PdfPageFormat.mm,
        marginTop: 8 * PdfPageFormat.mm,
        marginBottom: 8 * PdfPageFormat.mm,
      ),
      textDirection: pw.TextDirection.rtl,
      build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, mainAxisSize: pw.MainAxisSize.min, children: [
        pw.Text(generatorName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: narrow ? 14 : 20, fontWeight: pw.FontWeight.bold, color: blue)),
        pw.Text('إيصال دفع اشتراك', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: narrow ? 10 : 12)),
        pw.Text(r.number, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9, color: grey)),
        pw.Divider(color: grey, borderStyle: pw.BorderStyle.dashed),
        row('المشترك', r.subscriberName),
        row('رقم الجوزة', r.subscriberCircuit),
        if (r.subscriberPhone.isNotEmpty) row('الهاتف', r.subscriberPhone),
        row('الأمبيرات', '${r.subscriberAmbers} أمبير'),
        row('الشهر', r.label),
        row('سعر الأمبير', r.formattedPrice),
        pw.Divider(color: grey, borderStyle: pw.BorderStyle.dashed),
        row('المبلغ المدفوع', r.formattedAmount, strong: true),
        pw.Divider(color: grey, borderStyle: pw.BorderStyle.dashed),
        row('المحصّل', r.workerName ?? 'المدير'),
        row('التاريخ', Fmt.dateTime(r.dateReceived)),
        if (r.notes.isNotEmpty) row('ملاحظات', r.notes),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: subscriberQrData(r.subscriberId, r.generatorId),
            width: narrow ? 70 : 90,
            height: narrow ? 70 : 90,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text('شكراً لاشتراككم', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: narrow ? 9 : 11)),
      ]),
    ));
    return doc.save();
  }

  /// System print dialog (A4/A5 printers and 80 mm thermal printers).
  static Future<void> printReceipt(Receipt r, String generatorName) => Printing.layoutPdf(
        name: 'receipt_${r.id}',
        format: PdfPageFormat.roll80,
        onLayout: (format) => build(r, generatorName, format),
      );

  /// Share / save the receipt as a PDF file.
  static Future<void> sharePdf(Receipt r, String generatorName) async => Printing.sharePdf(
        bytes: await build(r, generatorName, PdfPageFormat.a6),
        filename: 'receipt_${r.id}.pdf',
      );
}
