import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/api/workers_api.dart';
import "../models/model.dart";

class WorkerService extends GetxService {
  final RxList<Gen_Worker> workers_list = <Gen_Worker>[].obs;
  final WorkerRepository api = WorkerRepository();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getWorkers();
  }

  Future<void> getWorkers() async {
    final workerList = await api.fetchWorkers();
    workers_list.assignAll(workerList);
  }

  Future<void> addWorker(Gen_Worker worker) async {
    final createdWorker = await api.createWorker(worker);
    workers_list.add(createdWorker);
  }

  Future<void> updateWorker(Gen_Worker worker) async {
    final updatedWorker = await api.updateWorker(worker.id, worker);
    final index = workers_list.indexWhere((w) => w.id == worker.id);
    if (index != -1) {
      workers_list[index] = updatedWorker;
    }
  }

  Future<void> removeWorker(Gen_Worker worker) async {
    await api.deleteWorker(worker.id);
    workers_list.remove(worker);
  }

  Gen_Worker? getWorkerById(int id) {
    return workers_list.firstWhere((w) => w.id == id);
  }
}
