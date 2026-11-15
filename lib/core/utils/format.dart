import 'package:intl/intl.dart';

/// Number / date formatting shared by every screen.
abstract class Fmt {
  static const currency = 'د.ع';

  static const months = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static final _int = NumberFormat('#,##0', 'en');
  static final _dec = NumberFormat('#,##0.##', 'en');

  static String monthName(int month) =>
      (month >= 1 && month <= 12) ? months[month] : '$month';

  /// 1250000 → "1,250,000"
  static String number(num v) => _int.format(v.round());

  /// 1250000 → "1,250,000 د.ع"
  static String money(num v) => '${number(v)} $currency';

  /// Short form for tight spots: 1250000 → "1.25 مليون", 65000 → "65 ألف"
  static String compactMoney(num v) {
    final a = v.abs();
    if (a >= 1000000) return '${_dec.format(v / 1000000)} مليون';
    if (a >= 1000) return '${_dec.format(v / 1000)} ألف';
    return number(v);
  }

  /// Axis labels: 1250000 → "1.3M", 65000 → "65K"
  static String axis(num v) {
    final a = v.abs();
    if (a >= 1000000) return '${NumberFormat('#,##0.#', 'en').format(v / 1000000)}M';
    if (a >= 1000) return '${NumberFormat('#,##0', 'en').format(v / 1000)}K';
    return number(v);
  }

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  /// 2026/10/17
  static String date(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  /// 17 أكتوبر 2026
  static String longDate(DateTime d) => '${d.day} ${monthName(d.month)} ${d.year}';

  /// 09:45
  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String dateTime(DateTime d) => '${date(d)}  ${time(d)}';

  static String greeting(DateTime now) {
    if (now.hour < 12) return 'صباح الخير';
    if (now.hour < 18) return 'مساء الخير';
    return 'مساء النور';
  }
}
