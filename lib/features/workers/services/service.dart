import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/repositories/repository.dart';
import "../models/model.dart";

class WorkerService extends GetxService {
  // Example: Simulated worker data
  final RxList<Gen_Worker> workers = <Gen_Worker>[].obs;

  Future<WorkerService> init() async {
    // Initialization logic here
    await fetchWorkers();

    return this;
  }

  Future<void> fetchWorkers() async {
    final repository = WorkerRepository();
    try {
      final workerList = await repository.fetchWorkers();
      workers.assignAll(workerList); // ✅ assign full Worker objects
    } catch (e) {
      print('💥 Worker fetch failed: $e');
    }
  }

  void addWorker(Gen_Worker w) {
    final repository = WorkerRepository();
    repository.createWorker(w);

    workers.add(w);
  }

  void updateWorker(Gen_Worker w) {}

  void removeWorker(Gen_Worker w) {
    final repository = WorkerRepository();

    repository.deleteWorker(w.id);
    workers.remove(w);
  }
}
