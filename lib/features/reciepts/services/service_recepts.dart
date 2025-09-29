import 'package:get/get.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/reciepts/models/receipt_model.dart';
import 'package:moalidaty/features/reciepts/api/receipt_api.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/workers/services/service_worker.dart';

class ReceiptServices extends GetxService {
  final RxList<Reciept> receiptsList = <Reciept>[].obs;
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
    receiptsList.assignAll(fetchedReciepts);
  }

  Future<void> addReciept(Reciept reciept) async {
    final createdReceipt = await recieptApi.createReciept(reciept);
    receiptsList.add(createdReceipt);
  }

  Future<bool> removeReceipt(Reciept reciept) async {
    if (await recieptApi.destroyReciept(reciept.id!)) {
      receiptsList.remove(reciept);
      return true;
    }
    return false;
  }

  Future<void> editReciept(Reciept reciept) async {
    final updatedReceipt = await recieptApi.updateReciept(reciept);
    final index = receiptsList.indexWhere((r) => r.id == reciept.id);
    if (index != -1) {
      receiptsList[index] = updatedReceipt;
    } else {}
  }

  Reciept? getReceiptById(int id) {
    return receiptsList.firstWhere((r) => r.id == id);
  }

  List<Reciept> getReceiptsBySubscriber(int subscriber) {
    return receiptsList.where((r) => r.subscriber == subscriber).toList();
  }

  List<Reciept> getReceiptsByYearMonth(int year, int month) {
    return receiptsList
        .where((r) => r.year == year && r.month == month)
        .toList();
  }
}
