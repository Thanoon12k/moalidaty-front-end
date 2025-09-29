import 'package:get/get.dart';
import 'package:moalidaty/features/workers/api/workers_api.dart';
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

  Future<bool> getWorkers() async {
    final workerList = await api.fetchWorkers();
    if (workerList != null) {
      workersList.assignAll(workerList);
      return true;
    }
    return false;
  }

  Future<bool> addWorker(Gen_Worker worker) async {
    if (await api.createWorker(worker)) {
      workersList.add(worker);
      return true;
    }
    return false;
  }

  Future<bool> updateWorker(Gen_Worker worker) async {
    if (await api.updateWorker(worker)) {
      final index = workersList.indexWhere((w) => w.id == worker.id);
      workersList[index] = worker;
      return true;
    }
    return false;
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
