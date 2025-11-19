import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/Account/models/account_model.dart';

class WorkersApi {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Account>?> fetchWorkers() async {
    String fetchUrl = "$baseUrl/account/";
    final response = await http.get(Uri.parse(fetchUrl));
    List<Account> accounts = [];
    if (response.statusCode == 200) {
      List<dynamic> json_data = json.decode(response.body);
       accounts = json_data
          .map((account_json) => Account.fromJson(account_json))
          .toList();
    }
    debugPrint(
      "Fetched accounts status: ${response.statusCode} got (${accounts.length}) items",
    );
    return accounts.isNotEmpty ? accounts : null;
  }

  Future<Account> fetchWorkerDetail(int id) async {
    String fetchUrl = "$baseUrl/account/$id/";

    final response = await http.get(Uri.parse(fetchUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      return Account.fromJson(jsonData);
    } else {
      throw Exception(
        "Failed to fetch worker detail from $fetchUrl. Status: ${response.statusCode}",
      );
    }
  }

  Future<bool> createWorker(Account worker) async {
    String createUrl = "$baseUrl/account/";
    final response = await http.post(
      Uri.parse(createUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(worker.toJson()),
    );

    return (response.statusCode == 201);
  }

  Future<bool> updateWorker(Account worker) async {
    String updateUrl = "$baseUrl/account/${worker.id}/";

    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(worker.toJson()),
    );

    return (response.statusCode == 200);
  }

  Future<bool> destroyWorker(int id) async {
    String deleteUrl = "$baseUrl/account/$id/";

    final response = await http.delete(Uri.parse(deleteUrl));

    return response.statusCode == 204;
  }
}
