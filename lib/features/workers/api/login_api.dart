import 'dart:convert';

import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/Account/models/account_model.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty/features/workers/models/workers_model.dart';

class WorkerLoginApi {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<MyWorker?> apiLoginWorker(String identifier, String password) async {
    final login_url = '$baseUrl/worker/login/';
    final response = await http.post(
      Uri.parse(login_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"identifier": identifier, "password": password}),
    );

    if (response.statusCode > 201) return null;

    final worker = MyWorker.fromJson(json.decode(response.body));
    return worker;
  }
}
