import '../../../core/data/collection_controller.dart';
import '../models/worker.dart';

class WorkerController extends CollectionController<Worker> {
  @override
  String get cacheName => 'workers';

  @override
  Future<List<Worker>> fetch() => ds.fetchWorkers();

  @override
  Worker fromRow(Map<String, dynamic> row) => Worker.fromRow(row);

  @override
  Map<String, dynamic> toRow(Worker item) => item.toRow();

  List<Worker> get active => items.where((w) => w.isActive).toList();

  Future<Worker> create(String name, String phone, String password) async {
    final w = await ds.createWorker(name, phone, password);
    items.add(w);
    _sort();
    return w;
  }

  Future<Worker> edit(int id, String name, String phone) async {
    final w = await ds.updateWorker(id, name, phone);
    _replace(w);
    return w;
  }

  Future<void> setPassword(int id, String password) => ds.setWorkerPassword(id, password);

  Future<Worker> setActive(int id, bool active) async {
    final w = await ds.setWorkerActive(id, active);
    _replace(w);
    return w;
  }

  void _replace(Worker w) {
    final i = items.indexWhere((x) => x.id == w.id);
    if (i >= 0) items[i] = w;
    _sort();
  }

  void _sort() => items.sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return a.name.compareTo(b.name);
      });
}
