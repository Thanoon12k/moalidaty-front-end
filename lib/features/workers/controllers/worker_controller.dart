import 'package:get/get.dart';

import 'package:moalidaty/features/workers/api/workers_api.dart';
import 'package:moalidaty/features/workers/models/workers_model.dart';

class WorkerController extends GetxService {
  final RxList<MyWorker> workersList = <MyWorker>[].obs;
  final RxBool showSearch = false.obs;
  final RxString searchQuery = ''.obs;
  MyWorker? myworker;

  final WorkerRepository api = WorkerRepository();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getWorkers();
  }

  List<MyWorker> get filteredWorkers {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return workersList;
    return workersList.where((worker) {
      return worker.username.toLowerCase().contains(query);
    }).toList();
  }

  Future<bool> getWorkers() async {
    final workerList = await api.apiFetchWorkers();
    if (workerList != null) {
      workersList.assignAll(workerList);
      return true;
    }
    return false;
  }

  Future<bool> addWorker(MyWorker worker) async {
    if (await api.apiCreateWorker(worker)) {
      workersList.add(worker);
      return true;
    }
    return false;
  }

  Future<bool> updateWorker(MyWorker worker) async {
    if (await api.apiUpdateWorker(worker)) {
      final index = workersList.indexWhere((w) => w.id == worker.id);
      workersList[index] = worker;
      return true;
    }
    return false;
  }

  Future<bool> removeWorker(int id) async {
    if (await api.apiDestroyWorker(id)) {
      workersList.removeWhere((w) => w.id == id);
      return true;
    }
    return false;
  }

  MyWorker? getWorkerById(int id) {
    return workersList.firstWhere((w) => w.id == id);
  }
}
