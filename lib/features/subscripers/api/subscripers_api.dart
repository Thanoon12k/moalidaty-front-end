import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';

class SubscriperAPI {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Subscriper>> fetchSubscribers() async {
    String fetchUrl = "$baseUrl/subscribers/";
    List<Subscriper> subscripersList = [];
    final response = await http.get(Uri.parse(fetchUrl));

    if (response.statusCode == 200) {
      List<dynamic> listData = json.decode(response.body);
      subscripersList = listData
          .map((jsonRow) => Subscriper.fromJson(jsonRow))
          .toList();
    }
    debugPrint(
      "Fetched Subscripers status: ${response.statusCode} got (${subscripersList.length}) items }",
    );
    return subscripersList;
  }

  Future<bool> destroySubscriper(int id) async {
    final String destroyUrl = "$baseUrl/subscribers/$id/";
    final response = await http.delete(Uri.parse(destroyUrl));
    return response.statusCode == 204;
  }

  Future<Subscriper> createSubscriper(Subscriper sub) async {
    final String createUrl = "$baseUrl/subscribers/";
    final response = await http.post(
      Uri.parse(createUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sub.toJson()),
    );
    debugPrint("going to post create sob ${jsonEncode(sub.toJson())}");
    if (response.statusCode == 201) {
      final createdSub = Subscriper.fromJson(json.decode(response.body));
      return createdSub;
    } else {
      throw Exception(
        'Failed to create subscriber. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
    // } catch (e, stackTrace) {

    //   rethrow;
    //   throw Exception('Error in creating subscriber: $e');
    // }
  }

  Future<Subscriper> updateSubscriper(Subscriper sub) async {
    final String updateUrl = "$baseUrl/subscribers/${sub.id}/";

    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sub.toJson()),
    );

    if (response.statusCode == 200) {
      final updatedSub = Subscriper.fromJson(json.decode(response.body));
      return updatedSub;
    } else {
      throw Exception(
        'Failed to update subscriber. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
    // } catch (e, stackTrace) {

    //   rethrow;
    //   throw Exception('Error in updating subscriber: $e');
    // }
  }
}
