import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/reciepts/models/receipt_model.dart';
import 'package:moalidaty1/features/reciepts/api/receipt_api.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';

class ReceiptServices extends GetxService {
  final RxList<Reciept> list_rcpts = <Reciept>[].obs;
  final RxList<Reciept> list_subs = <Reciept>[].obs;
  final RxList<Reciept> list_budg = <Reciept>[].obs;

  final recieptApi = RecieptAPI();
  final sub_service = Get.find<SubscribersService>();
  final worker_Service = Get.find<WorkerService>();
  final budget_service = Get.find<BudgetService>();
  @override
  Future<void> onInit() async {
    super.onInit();
    await getReciepts();
    // } catch (e, stackTrace) {

    //   rethrow;

    // }
  }

  Future<void> getReciepts() async {
    final fetchedReciepts = await recieptApi.fetchReciepts();

    fetchedReciepts.sort((a, b) => b.dateCreated!.compareTo(a.dateCreated!));
    list_rcpts.assignAll(fetchedReciepts);
  }

  Future<void> addReciept(Reciept reciept) async {
    final createdReceipt = await recieptApi.createReciept(reciept);
    list_rcpts.add(createdReceipt);
  }

  Future<void> deleteReciept(Reciept reciept) async {
    if (reciept.id == null) {
      throw Exception('Cannot delete receipt without an ID');
    }

    await recieptApi.destroyReciept(reciept.id!);
    list_rcpts.remove(reciept);
  }

  Future<void> editReciept(Reciept reciept) async {
    final updatedReceipt = await recieptApi.updateReciept(reciept);
    final index = list_rcpts.indexWhere((r) => r.id == reciept.id);
    if (index != -1) {
      list_rcpts[index] = updatedReceipt;
    } else {}
  }

  Reciept? getReceiptById(int id) {
    return list_rcpts.firstWhere((r) => r.id == id);
  }

  List<Reciept> getReceiptsBySubscriber(int subscriber) {
    return list_rcpts.where((r) => r.subscriber == subscriber).toList();
  }

  List<Reciept> getReceiptsByYearMonth(int year, int month) {
    return list_rcpts.where((r) => r.year == year && r.month == month).toList();
  }
}
