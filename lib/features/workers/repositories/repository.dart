import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/workers/models/model.dart';

class WorkerRepository {
  final String baseUrl = GlobalConstants.baseAddress;

  Future<List<Gen_Worker>> fetchWorkers() async {
    String fetchUrl = "$baseUrl/workers/";

    try {
      final response = await http.get(Uri.parse(fetchUrl));

      if (response.statusCode == 200) {
        List listData = json.decode(response.body);
        return listData.map((jsonRow) => Gen_Worker.fromJson(jsonRow)).toList();
      } else {
        throw Exception(
          "Failed to fetch workers from $fetchUrl. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error in fetching workers: $e");
    }
  }

  Future<Gen_Worker> fetchWorkerDetail(int id) async {
    String fetchUrl = "$baseUrl/workers/$id/";

    try {
      final response = await http.get(Uri.parse(fetchUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        return Gen_Worker.fromJson(jsonData);
      } else {
        throw Exception(
          "Failed to fetch worker detail from $fetchUrl. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error in fetching worker detail: $e");
    }
  }

  Future<Gen_Worker> createWorker(Gen_Worker worker) async {
    String createUrl = "$baseUrl/workers/";

    try {
      final response = await http.post(
        Uri.parse(createUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(worker.toJson()),
      );

      if (response.statusCode == 201) {
        final createdWorker = Gen_Worker.fromJson(json.decode(response.body));
        return createdWorker;
      } else {
        throw Exception(
          'Failed to create worker. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error in creating worker: $e');
    }
  }

  Future<Gen_Worker> updateWorker(int id, Gen_Worker worker) async {
    String updateUrl = "$baseUrl/workers/$id/";

    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(worker.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedWorker = Gen_Worker.fromJson(json.decode(response.body));
        return updatedWorker;
      } else {
        throw Exception(
          'Failed to update worker. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error in updating worker: $e');
    }
  }

  Future<void> deleteWorker(int id) async {
    String deleteUrl = "$baseUrl/workers/$id/";

    try {
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode != 204) {
        throw Exception(
          "Failed to delete worker from $deleteUrl. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error in deleting worker: $e");
    }
  }
}
