import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/reciepts/models/model.dart';

class RecieptRepository {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Reciept>> fetchReciepts() async {
    String fetchUrl = "$baseUrl/reciepts";
    try {
      final response = await http.get(Uri.parse(fetchUrl));

      if (response.statusCode == 200) {
        List listData = json.decode(response.body);
        return listData.map((jsonRow) => Reciept.fromJson(jsonRow)).toList();
      } else {
        throw Exception(
          "Failed to fetch reciepts from $fetchUrl   <<<   ${response.statusCode} >>>",
        );
      }
    } catch (e) {
      throw Exception("Error in fetching reciepts:<< $e >>");
    }
  }

  Future<Reciept> createReciept(Reciept reciept) async {
    final String createUrl = "$baseUrl/reciepts/";
    final response = await http.post(
      Uri.parse(createUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reciept.toJson()),
    );

    if (response.statusCode == 201) {
      return Reciept.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create reciept    <<< ${response.statusCode} >>>: ${response.body}',
      );
    }
  }

  Future<void> destroyReciept(int id) async {
    final String deleteUrl = "$baseUrl/reciepts/$id/";
    final response = await http.delete(Uri.parse(deleteUrl));

    if (response.statusCode != 204) {
      throw Exception(
        "Failed to delete reciept from $deleteUrl   <<< ${response.statusCode} >>>",
      );
    }
  }

  Future<Reciept> updateReciept(Reciept reciept) async {
    final String updateUrl = "$baseUrl/reciepts/${reciept.id}/";
    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reciept.toJson()),
    );

    if (response.statusCode == 200) {
      return Reciept.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update reciept   <<< ${response.statusCode} >>>: ${response.body}',
      );
    }
  }
}
