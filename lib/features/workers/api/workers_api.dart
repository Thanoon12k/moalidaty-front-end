import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';

class WorkerRepository {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<MyWorker>?> apiFetchWorkers() async {
    String fetchUrl = "$baseUrl/workers/";
    final response = await http.get(Uri.parse(fetchUrl));
    List<MyWorker> workers_list = [];
    if (response.statusCode == 200) {
      List<dynamic> listData = json.decode(response.body);
      workers_list = listData
          .map((json_worker) => MyWorker.fromJson(json_worker))
          .toList();
    }

    debugPrint(
      "Fetched Workers status: ${response.statusCode} got (${workers_list.length}) items",
    );
    return workers_list.isNotEmpty ? workers_list : null;
  }

  Future<MyWorker> apiFetchWorkerDetail(int id) async {
    String fetchUrl = "$baseUrl/workers/$id";

    final response = await http.get(Uri.parse(fetchUrl));
    debugPrint(
      "fetch workerdetails status(${response.statusCode}) response is : ${response.body}",
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      return MyWorker.fromJson(jsonData);
    } else {
      throw Exception(
        "Failed to fetch worker detail from $fetchUrl. Status: ${response.statusCode}",
      );
    }
  }

  Future<bool> apiCreateWorker(MyWorker worker) async {
    String createUrl = "$baseUrl/workers/";
    final response = await http.post(
      Uri.parse(createUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(worker.toJson()),
    );
    debugPrint(
      "create worker status(${response.statusCode})  response is : ${response.body}",
    );
    return (response.statusCode == 201);
  }

  Future<bool> apiUpdateWorker(MyWorker worker) async {
    String updateUrl = "$baseUrl/workers/${worker.id}";

    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(worker.toJson()),
    );
    debugPrint(
      "update worker status(${response.statusCode}) response is : ${response.body}",
    );

    return (response.statusCode == 200);
  }

  Future<bool> apiDestroyWorker(int id) async {
    String deleteUrl = "$baseUrl/workers/$id";

    final response = await http.delete(Uri.parse(deleteUrl));
    debugPrint(
      "destroy worker status(${response.statusCode}) response is : ${response.body}",
    );

    return response.statusCode == 204;
  }
}
