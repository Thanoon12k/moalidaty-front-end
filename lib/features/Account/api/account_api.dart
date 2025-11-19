import 'dart:convert';

import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/Account/models/account_model.dart';
import 'package:http/http.dart' as http;

class AccountApi {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<Account?> apiLoginUser(String identifier, String password) async {
    final login_url = '$baseUrl/account/login/';
    final response = await http.post(
      Uri.parse(login_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"identifier": identifier, "password": password}),
    );

    if (response.statusCode > 201) return null;

    final account = Account.fromJson(json.decode(response.body));
    return account;
  }
}
