import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/api/workers_api.dart';
import "../models/model.dart";

class WorkerService extends GetxService {
  final RxList<Gen_Worker> workers_list = <Gen_Worker>[].obs;
  final WorkerRepository repository = WorkerRepository();

  @override
  Future<void> onInit() async {
    super.onInit();
    // ttry {
    await getWorkers();
    // } catch (e, stackTrace) {

    //   rethrow;

    // }
  }

  Future<void> getWorkers() async {
    // ttry {
    final workerList = await repository.fetchWorkers();
    workers_list.assignAll(workerList);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   // Continue with empty list instead of failing completely
    // }
  }

  Future<void> addWorker(Gen_Worker worker) async {
    // ttry {
    final createdWorker = await repository.createWorker(worker);
    workers_list.add(createdWorker);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> updateWorker(Gen_Worker worker) async {
    // ttry {
    final updatedWorker = await repository.updateWorker(worker.id, worker);
    final index = workers_list.indexWhere((w) => w.id == worker.id);
    if (index != -1) {
      workers_list[index] = updatedWorker;
    }
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> removeWorker(Gen_Worker worker) async {
    // ttry {
    await repository.deleteWorker(worker.id);
    workers_list.remove(worker);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Gen_Worker? getWorkerById(int id) {
    // ttry {
    return workers_list.firstWhere((w) => w.id == id);
    // } catch (e, stackTrace) {

    //   rethrow;
    //   rethrow;
    //   return null;
    // }
  }
}
