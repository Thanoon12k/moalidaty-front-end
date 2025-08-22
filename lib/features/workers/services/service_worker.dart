import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/repositories/repository.dart';
import "../models/model.dart";

class WorkerService extends GetxService {
  final RxList<Gen_Worker> workers = <Gen_Worker>[].obs;
  final WorkerRepository repository = WorkerRepository();

  @override
  Future<void> onInit() async {
    print('WorkerService: onInit called');

    super.onInit();
    try {
      await getWorkers();
    } catch (e) {
      print('WorkerService: Error in onInit: $e');
    }
  }

  Future<void> getWorkers() async {
    try {
      print('WorkerService: Starting to fetch workers');
      final workerList = await repository.fetchWorkers();
      print('WorkerService: Fetched ${workerList.length} workers');
      workers.assignAll(workerList);
    } catch (e) {
      print('WorkerService: Error fetching workers: $e');
      // Continue with empty list instead of failing completely
    }
  }

  Future<void> addWorker(Gen_Worker worker) async {
    try {
      final createdWorker = await repository.createWorker(worker);
      workers.add(createdWorker);
    } catch (e) {
      print('Error adding worker: $e');
      rethrow;
    }
  }

  Future<void> updateWorker(Gen_Worker worker) async {
    try {
      final updatedWorker = await repository.updateWorker(worker.id, worker);
      final index = workers.indexWhere((w) => w.id == worker.id);
      if (index != -1) {
        workers[index] = updatedWorker;
      }
    } catch (e) {
      print('Error updating worker: $e');
      rethrow;
    }
  }

  Future<void> removeWorker(Gen_Worker worker) async {
    try {
      await repository.deleteWorker(worker.id);
      workers.remove(worker);
    } catch (e) {
      print('Error removing worker: $e');
      rethrow;
    }
  }

  Gen_Worker? getWorkerById(int id) {
    try {
      return workers.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }
}
