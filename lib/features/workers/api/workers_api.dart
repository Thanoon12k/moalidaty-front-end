import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';

class WorkerRepository {
  final String baseUrl = GlobalConstants.baseAddress;
  late final Dio _dio;

  WorkerRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<List<MyWorker>?> apiFetchWorkers() async {
    try {
      final response = await _dio.get('/workers/');
      List<MyWorker> workers_list = [];

      if (response.statusCode == 200) {
        List<dynamic> listData = response.data;
        workers_list = listData
            .map((json_worker) => MyWorker.fromJson(json_worker))
            .toList();
      }

      debugPrint(
        "Fetched Workers status: ${response.statusCode} got (${workers_list.length}) items",
      );
      return workers_list.isNotEmpty ? workers_list : null;
    } on DioException catch (e) {
      debugPrint("❌ Dio error in apiFetchWorkers: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("❌ Unexpected error in apiFetchWorkers: $e");
      return null;
    }
  }

  Future<MyWorker?> apiFetchWorkerDetail(int id) async {
    try {
      final response = await _dio.get('/workers/$id');

      debugPrint(
        "fetch workerdetails status(${response.statusCode}) response is : ${response.data}",
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = response.data;
        return MyWorker.fromJson(jsonData);
      } else {
        throw Exception(
          "Failed to fetch worker detail. Status: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      debugPrint("❌ Dio error in apiFetchWorkerDetail: ${e.message}");
      if (e.response?.statusCode == 404) {
        debugPrint("❌ Worker with id $id not found");
      }
      throw Exception(
        "Failed to fetch worker detail. Status: ${e.response?.statusCode}",
      );
    } catch (e) {
      debugPrint("❌ Unexpected error in apiFetchWorkerDetail: $e");
      rethrow;
    }
  }

  Future<bool> apiCreateWorker(MyWorker worker) async {
    try {
      final response = await _dio.post('/workers/', data: worker.toJson());

      debugPrint(
        "create worker status(${response.statusCode}) response is : ${response.data}",
      );

      return (response.statusCode == 201);
    } on DioException catch (e) {
      debugPrint("❌ Dio error in apiCreateWorker: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("❌ Unexpected error in apiCreateWorker: $e");
      return false;
    }
  }

  Future<bool> apiUpdateWorker(MyWorker worker) async {
    try {
      final response = await _dio.put(
        '/workers/${worker.id}',
        data: worker.toJson(),
      );

      debugPrint(
        "update worker status(${response.statusCode}) response is : ${response.data}",
      );

      return (response.statusCode == 200);
    } on DioException catch (e) {
      debugPrint("❌ Dio error in apiUpdateWorker: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("❌ Unexpected error in apiUpdateWorker: $e");
      return false;
    }
  }

  Future<bool> apiDestroyWorker(int id) async {
    try {
      final response = await _dio.delete('/workers/$id');

      debugPrint(
        "destroy worker status(${response.statusCode}) response is : ${response.data}",
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("❌ Dio error in apiDestroyWorker: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("❌ Unexpected error in apiDestroyWorker: $e");
      return false;
    }
  }
}
