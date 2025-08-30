import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/api/workers_api.dart';
import "../models/model.dart";

class WorkerService extends GetxService {
  final RxList<Gen_Worker> workersList = <Gen_Worker>[].obs;
  final WorkerRepository api = WorkerRepository();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getWorkers();
  }

  Future<void> getWorkers() async {
    final workerList = await api.fetchWorkers();
    workersList.assignAll(workerList);
  }

  Future<void> addWorker(Gen_Worker worker) async {
    final createdWorker = await api.createWorker(worker);
    workersList.add(createdWorker);
  }

  Future<void> updateWorker(Gen_Worker worker) async {
    final updatedWorker = await api.updateWorker(worker.id, worker);
    final index = workersList.indexWhere((w) => w.id == worker.id);
    if (index != -1) {
      workersList[index] = updatedWorker;
    }
  }

  Future<void> removeWorker(Gen_Worker worker) async {
    await api.deleteWorker(worker.id);
    workersList.remove(worker);
  }

  Gen_Worker? getWorkerById(int id) {
    return workersList.firstWhere((w) => w.id == id);
  }
}
