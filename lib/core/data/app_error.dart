import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// An error whose message is already meant for the user.
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// True when the failure is "no connection" rather than a rejected request —
/// those receipts go to the offline queue instead of being dropped.
bool isNetworkError(Object e) {
  if (e is TimeoutException || e is http.ClientException) return true;
  if (e is AuthRetryableFetchException) return true;
  final s = e.toString();
  return s.contains('SocketException') ||
      s.contains('Failed host lookup') ||
      s.contains('Connection refused') ||
      s.contains('Connection closed') ||
      s.contains('XMLHttpRequest error') ||
      s.contains('Failed to fetch') ||
      s.contains('Network is unreachable');
}

/// Turns any backend failure into an Arabic sentence.
String describeError(Object e) {
  if (e is AppException) return e.message;
  if (isNetworkError(e)) return 'تعذر الاتصال بالخادم، تحقق من اتصال الإنترنت';

  if (e is AuthException) {
    final code = e.code ?? '';
    if (code == 'invalid_credentials' || e.message.contains('Invalid login credentials')) {
      return 'بيانات الدخول غير صحيحة';
    }
    if (code == 'user_banned') return 'هذا الحساب موقوف، راجع مدير المولدة';
    if (code == 'over_request_rate_limit' || e.statusCode == '429') {
      return 'محاولات كثيرة، انتظر قليلاً ثم أعد المحاولة';
    }
    if (code == 'weak_password') return 'كلمة المرور ضعيفة';
    if (code == 'same_password') return 'كلمة المرور الجديدة مطابقة للقديمة';
    return 'تعذر تسجيل الدخول، حاول مرة أخرى';
  }

  if (e is PostgrestException) {
    final msg = e.message;
    switch (e.code) {
      case '23505':
        if (msg.contains('receipts_one_per_month')) return 'يوجد إيصال لهذا المشترك في هذا الشهر مسبقاً';
        if (msg.contains('budgets_one_per_month')) return 'الميزانية لهذا الشهر موجودة مسبقاً';
        if (msg.contains('workers_phone_key') || msg.contains('accounts_phone_key')) {
          return 'رقم الهاتف مستخدم مسبقاً';
        }
        if (msg.contains('accounts_generator_name_key')) return 'اسم المولدة مستخدم مسبقاً';
        return 'هذه البيانات موجودة مسبقاً';
      case '23514':
      case '22P02':
        return 'بعض الحقول تحتوي على قيم غير صالحة';
      case '23503':
        return 'العنصر المرتبط غير موجود';
      case '42501':
        return _isArabic(msg) ? msg : 'ليست لديك صلاحية لهذه العملية';
      case 'P0001':
        return msg;
      case 'PGRST301':
      case 'PGRST303':
        return 'انتهت الجلسة، سجّل الدخول من جديد';
    }
    if (_isArabic(msg)) return msg;
  }
  return 'حدث خطأ غير متوقع، حاول مرة أخرى';
}

bool _isArabic(String s) => RegExp(r'[؀-ۿ]').hasMatch(s);
