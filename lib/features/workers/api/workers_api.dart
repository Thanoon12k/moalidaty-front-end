import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/workers/models/model.dart';

class WorkerRepository {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Gen_Worker>?> fetchWorkers() async {
    String fetchUrl = "$baseUrl/workers/";
    final response = await http.get(Uri.parse(fetchUrl));
    List<Gen_Worker> genWorkersList = [];
    if (response.statusCode == 200) {
      List<dynamic> listData = json.decode(response.body);
      genWorkersList = listData
          .map((jsonRow) => Gen_Worker.fromJson(jsonRow))
          .toList();
    }
    debugPrint(
      "Fetched Workers status: ${response.statusCode} got (${genWorkersList.length}) items",
    );
    return genWorkersList.isNotEmpty ? genWorkersList : null;
  }

  Future<Gen_Worker> fetchWorkerDetail(int id) async {
    String fetchUrl = "$baseUrl/workers/$id/";

    final response = await http.get(Uri.parse(fetchUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      return Gen_Worker.fromJson(jsonData);
    } else {
      throw Exception(
        "Failed to fetch worker detail from $fetchUrl. Status: ${response.statusCode}",
      );
    }
    // } catch (e, stackTrace) {

    //   rethrow;
    //   throw Exception("Error in fetching worker detail: $e");
    // }
  }

  Future<bool> createWorker(Gen_Worker worker) async {
    String createUrl = "$baseUrl/workers/";
    final response = await http.post(
      Uri.parse(createUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(worker.toJson()),
    );

    return (response.statusCode == 201);
  }

  Future<bool> updateWorker(Gen_Worker worker) async {
    String updateUrl = "$baseUrl/workers/${worker.id}/";

    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(worker.toJson()),
    );

    return (response.statusCode == 200);
  }

  Future<bool> destroyWorker(int id) async {
    String deleteUrl = "$baseUrl/workers/$id/";

    final response = await http.delete(Uri.parse(deleteUrl));

    return response.statusCode == 204;
  }
}
