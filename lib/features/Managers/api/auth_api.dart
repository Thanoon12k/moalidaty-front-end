import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/Managers/models/models.dart';
import 'package:http/http.dart' as http;

class ManagerApi {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Account>?> fetchManagers() async {
    final fetch_url = '$baseUrl/electricgenerator/';
    List<Account> fetched_list = [];

    final response = await http.get(Uri.parse(fetch_url));

    if (response.statusCode == 200) {
      List<dynamic> listData = json.decode(response.body);

      fetched_list = listData
          .map((jsonRow) => Account.fromJson(jsonRow))
          .toList();
    }

    return fetched_list.isNotEmpty ? fetched_list : null;
  }

  Future loginUser(identifier, password) async {
    bool login_status = false;

    final login_url = baseUrl + '/manager/login/';

    final response = await http.post(
      Uri.parse(login_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"identifier": identifier, "password": password}),
    );

    if (response.statusCode > 201) return null;

    final user_type = json.decode(response.body)['user-type'];

    if (user_type == 'manager') {
      Manager.fromJson( json.decode(response.body));
      Manager(generator_name: generator_name);
    } else if (user_type == 'worker') {
      return 'worker';
    }
    debugPrint("error in userType --> ${json.decode(response.body)}");
    return null;
  }
}
