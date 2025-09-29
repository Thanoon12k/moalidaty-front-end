import 'package:get/get.dart';
import 'package:moalidaty/features/budgets/models/budgets_model.dart';
import 'package:moalidaty/features/budgets/services/budget_service.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/subscripers/api/subscripers_api.dart';

class SubscribersService extends GetxService {
  final subApi = SubscriperAPI();

  final RxList<Subscriper> subscribersList = <Subscriper>[].obs;
  final RxBool showSearch = false.obs;
  final RxString searchQuery = ''.obs;

  List<Subscriper> get filteredSubscripers {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return subscribersList;
    return subscribersList.where((worker) {
      return worker.name.toLowerCase().contains(query);
    }).toList();
  }

  List<Budget> GetUnpaidsBudgetsForSubscriper(int subID) {
    final budgets = Get.find<BudgetService>().BudgetList;
    return budgets.where((bdgt) => bdgt.unpaid_subs.contains(subID)).toList();
  }

  List<Budget> GetpaidsBudgetsForSubscriper(int subID) {
    final budgets = Get.find<BudgetService>().BudgetList;
    return budgets.where((bdgt) => bdgt.paid_subs.contains(subID)).toList();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await getSubscripers();
    // } catch (e, stackTrace) {

    //   rethrow;

    // }
  }

  Future<void> getSubscripers() async {
    final fetchedSubs = await subApi.fetchSubscribers();
    subscribersList.assignAll(fetchedSubs);
  }

  Future<void> addSubsciper(Subscriper sub) async {
    final createdSub = await subApi.createSubscriper(sub);
    subscribersList.add(createdSub);
  }

  Future<bool> removeSubscriper(Subscriper sub) async {
    if (await subApi.destroySubscriper(sub.id)) {
      subscribersList.remove(sub);
      filteredSubscripers.remove(sub);
      return true;
    }
    return false;
  }

  Future<void> editSubscriper(Subscriper sub) async {
    final updatedSub = await subApi.updateSubscriper(sub);
    final index = subscribersList.indexWhere((s) => s.id == sub.id);
    if (index != -1) {
      subscribersList[index] = updatedSub;
    } else {}
  }

  Subscriper? getSubscriberById(int id) {
    return subscribersList.firstWhere((s) => s.id == id);
  }
}
