import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkerRepository {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Gen_Worker>> fetchWorkers() async {
    print('Fetching workers from: $baseUrl/workers/');

    final response = await http.get(Uri.parse('$baseUrl/workers/'));
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Gen_Worker.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load workers list');
    }
  }

  Future<Gen_Worker> fetchWorkerDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/workers/$id/'));
    if (response.statusCode == 200) {
      return Gen_Worker.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load worker detail with id $id');
    }
  }

  Future<Gen_Worker> createWorker(Gen_Worker worker) async {
    final response = await http.post(
      Uri.parse('$baseUrl/workers/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(worker.toJson()),
    );
    print('Create response: ${response.statusCode}');
    print('Create response body: ${response.body}');
    print('Worker to create: ${worker.toJson()}');
    if (response.statusCode == 201) {
      return Gen_Worker.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create worker');
    }
  }

  Future<Gen_Worker> updateWorker(int id, Gen_Worker worker) async {
    final response = await http.put(
      Uri.parse('$baseUrl/workers/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(worker.toJson()),
    );
    print('Update response: ${response.statusCode}');
    print('Update response body: ${response.body}');
    print('Worker to update: ${worker.toJson()}');
    if (response.statusCode == 200) {
      return Gen_Worker.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update worker name ${worker.name} with id $id',
      );
    }
  }

  Future<void> deleteWorker(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/workers/$id/'));
    print('Delete response: ${response.statusCode}');
    print('Delete response body: ${response.body}');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete worker with id $id');
    }
  }
}
