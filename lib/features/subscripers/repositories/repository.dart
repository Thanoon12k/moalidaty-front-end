import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';

class SubscriperRepository {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Subscriper>> fetchSubscribers() async {
    String fetchUrl = "$baseUrl/subsripers";

    List<Subscriper> subs = [];
    final response = await http.get(Uri.parse(fetchUrl));
    print("return subscriper from $fetchUrl");
    print("return subscriper code ${response.statusCode}");
    print("return subscriper body ${response.body}");

    if (response.statusCode == 200) {
      List list_data = json.decode(response.body);
      subs =
          list_data.map((json_row) => Subscriper.fromJson(json_row)).toList();
      return subs;
    } else {
      throw Exception("Failed to Fetch  subscripers from $fetchUrl");
    }
  }

  Future<void> destroySubscriper(int id) async {
    final String destroyUrl = "$baseUrl/subscripers/$id/";
    final response = await http.delete(Uri.parse(destroyUrl));
    print("delete response ${response.statusCode}");
    print("delete body${response.body}");
    if (response.statusCode != 204) {
      throw Exception("Failed to Fetch  subscripers from $destroyUrl");
    }
  }

  Future<Subscriper> createSubscriper(Subscriper sub) async {
    final String createUrl = "$baseUrl/subscripers";
    final response = await http.post(
      Uri.parse(createUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sub.toJson()),
    );

    print('Create response: ${response.statusCode}');
    print('Create response body: ${response.body}');
    print('sub to create: ${sub.toJson()}');
    if (response.statusCode == 201) {
      return sub;
    } else {
      throw Exception('Failed to create subscriper $sub');
    }
  }

  Future<Subscriper> updateSubscriper(sub) async {
    final String updateUrl = "$baseUrl/subscripers/${sub.id}";

    final response = await http.patch(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sub.toJson()),
    );
    print('update response: ${response.statusCode}');
    print('update response body: ${response.body}');
    print('sub to update: ${sub.toJson()}');
    if (response.statusCode == 200) {
      return sub;
    } else {
      throw Exception('Failed to update subscriper $sub');
    }
  }
}
