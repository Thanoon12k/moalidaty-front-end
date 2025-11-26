import 'package:moalidaty/features/Account/models/account_model.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';

class GlobalConstants {
  static const String baseAddress = "https://moalidaty.pythonanywhere.com";
  // static const String baseAddress = "http://localhost:8000";
  static String? AccountType;
  static String? GeneratorName;
  static int? accountID;
  static bool is_user = false;
  static Account? manager;
  static MyWorker? worker;
}
