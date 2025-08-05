import 'package:get/get.dart';
import 'package:moalidaty1/features/subscripers/ui/subscripersList.dart';
import 'package:moalidaty1/features/workers/ui/list_workers.dart';
import 'package:moalidaty1/main.dart';

final class Routes {
  static const String home = '/';
  static const String workerList = '/worker-list';
  static const String subscripersList = '/supscripers-list';

  static List<GetPage> get pages => [
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: workerList, page: () => WorkersListPage()),
    GetPage(name: subscripersList, page: () => subscripersListPage()),
  ];
}
