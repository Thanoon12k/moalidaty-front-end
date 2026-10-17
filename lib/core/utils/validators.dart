/// Form validators. The database enforces the same limits
/// (supabase/migrations), these give instant Arabic feedback.
abstract class Validators {
  static final _iraqiMobile = RegExp(r'^07[0-9]{9}$');

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'حقل مطلوب' : null;

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'حقل مطلوب';
    final n = v.trim().length;
    if (n < 2) return 'الاسم قصير جداً';
    if (n > 100) return 'الاسم طويل جداً (100 حرف كحد أقصى)';
    return null;
  }

  static String? circuit(String? v) {
    if (v == null || v.trim().isEmpty) return 'حقل مطلوب';
    if (v.trim().length > 20) return '20 حرفاً كحد أقصى';
    return null;
  }

  static String? ambers(String? v) {
    if (v == null || v.trim().isEmpty) return 'حقل مطلوب';
    final n = int.tryParse(v.trim());
    if (n == null || n < 1 || n > 200) return 'أدخل رقماً بين 1 و 200';
    return null;
  }

  /// Iraqi mobile: 07XXXXXXXXX
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'حقل مطلوب';
    return _iraqiMobile.hasMatch(normalizePhone(v)) ? null : 'رقم غير صالح (07XXXXXXXXX)';
  }

  static String? optionalPhone(String? v) =>
      (v == null || v.trim().isEmpty) ? null : phone(v);

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'حقل مطلوب';
    if (v.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    if (v.length > 72) return 'كلمة المرور طويلة جداً';
    return null;
  }

  static String? price(String? v) {
    if (v == null || v.trim().isEmpty) return 'حقل مطلوب';
    final n = double.tryParse(v.trim().replaceAll(',', ''));
    if (n == null || n <= 0) return 'أدخل سعراً صحيحاً';
    if (n > 10000000) return 'السعر كبير جداً';
    return null;
  }

  static String? amount(String? v) {
    if (v == null || v.trim().isEmpty) return 'حقل مطلوب';
    final n = double.tryParse(v.trim().replaceAll(',', ''));
    if (n == null || n < 0) return 'أدخل مبلغاً صحيحاً';
    return null;
  }

  /// Removes spaces / dashes and converts Arabic-Indic digits.
  static String normalizePhone(String v) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    final buf = StringBuffer();
    for (final ch in v.trim().split('')) {
      final i = arabic.indexOf(ch);
      if (i >= 0) {
        buf.write(i);
      } else if (RegExp(r'[0-9+]').hasMatch(ch)) {
        buf.write(ch);
      }
    }
    return buf.toString();
  }
}
