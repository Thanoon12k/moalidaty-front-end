import 'package:get/get.dart';
import 'package:moalidaty1/features/workers/ui/list_workers.dart';
import 'package:moalidaty1/main.dart';

final class Routes {
  static const String home = '/';
  static const String workerList = '/worker-list';
  static const String workerDetail = '/worker-detail';
  static const String workerCreate = '/worker-create';
  static const String workerUpdate = '/worker-update';

  static List<GetPage> get pages => [
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: workerList, page: () => WorkersListPage()),
    // GetPage(name: workerDetail, page: () => WorkerDetailPage()),
    // GetPage(name: workerCreate, page: () => WorkerCreatePage()),
    // GetPage(name: workerUpdate, page: () => WorkerUpdatePage()),
  ];
}
