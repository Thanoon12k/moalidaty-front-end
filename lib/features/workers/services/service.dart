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

  void updateWorker(Gen_Worker w) {
    final repository = WorkerRepository();

    repository.updateWorker(w.id, w).then((updatedWorker) {
      int index = workers.indexWhere((worker) => worker.id == w.id);
      if (index != -1) {
        workers[index] = updatedWorker; // Update the worker in the list
      }
    }).catchError((error) {
      print('Error updating worker: $error');
    });

  }

  void removeWorker(Gen_Worker w) {
    final repository = WorkerRepository();

    repository.deleteWorker(w.id);
    workers.remove(w);
  }
}
