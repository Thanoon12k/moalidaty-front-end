import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/api/workers_api.dart';
import "../models/model.dart";

class WorkerService extends GetxService {
  final RxList<Gen_Worker> workersList = <Gen_Worker>[].obs;
  final RxBool showSearch = false.obs;
  final RxString searchQuery = ''.obs;

  final WorkerRepository api = WorkerRepository();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getWorkers();
  }

  List<Gen_Worker> get filteredWorkers {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return workersList;
    return workersList.where((worker) {
      return worker.name.toLowerCase().contains(query);
    }).toList();
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

  Future<bool> removeWorker(Gen_Worker worker) async {
    if (await api.destroyWorker(worker.id)) {
      workersList.removeWhere((w) => w.id == worker.id);
      return true;
    }
    return false;
  }

  Gen_Worker? getWorkerById(int id) {
    return workersList.firstWhere((w) => w.id == id);
  }
}
