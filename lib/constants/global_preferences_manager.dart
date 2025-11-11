import 'package:moalidaty/features/Managers/models/models.dart';
import 'package:moalidaty/features/workers/models/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static final Future<SharedPreferences> _pref =
      SharedPreferences.getInstance();

  Future<void> registerUser(
    user_type,
    user_name,
    user_phone,
    date_created,
    user_id,
  ) async {
    final List<String> user_details = [
      user_type,
      user_name,
      user_phone,
      date_created,
      user_id,
    ];
    final prefs = await _pref;
    await prefs.setStringList('user_details', user_details);
  }

  Future<void> unRegisterUser() async {
    final prefs = await _pref;
    await prefs.remove('user_details');
  }

  Future<dynamic> getLoggedUser() async {
    final prefs = await _pref;
    late Gen_Worker? _worker;
    late Manager? _manager;

    final user_details = await prefs.getStringList('user_details');
    if (user_details != null && user_details[0] == 'manager') {
      _manager = Manager(
        generator_name: user_details[1],
        phone: user_details[2],
        date_created: user_details[3] as DateTime,
        id: user_details[4] as int,
      );
    } else if (user_details != null && user_details[0] == 'worker') {
      _worker = Gen_Worker(
        name: user_details[1],
        phone: user_details[2],
        date_created: user_details[3] as DateTime,
        id: user_details[4] as int,
      );
    }

    return _manager ?? _worker;
  }

  Future<bool> isUserManager() async {
    final prefs = await _pref;

    final user = await prefs.getStringList('user_details');
    if (user != null) {
      return user[0] == 'manager';
    }
    return false;
  }

  Future<bool> isUserWorker() async {
    final prefs = await _pref;

    final user = await prefs.getStringList('user_details');
    if (user != null) {
      return user[0] == 'worker';
    }
    return false;
  }

  Future<bool> isUserRegistered() async {
    final user = await getLoggedUser();
    return user != null;
  }
}
