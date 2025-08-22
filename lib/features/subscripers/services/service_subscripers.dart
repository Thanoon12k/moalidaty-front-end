
import 'package:get/get.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/repositories/repository.dart';

class SubscripersService extends GetxService {
  final RxList<Subscriper> list_subs = <Subscriper>[].obs;
  final sub_repository = SubscriperRepository();

  @override
  Future<void> onInit() async{
        print('SubscripersService: onInit called');

    super.onInit();
   try {
    await  getSubscripers();
    } catch (e) {
      print('SubscripersService: Error in onInit: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();
    print('SubscripersService: onClose called');
  }
 

  Future<void> getSubscripers() async {
    try {
      print('SubscripersService: Starting to fetch subscribers');
      final fetchedSubs = await sub_repository.fetchSubscribers();
      print('SubscripersService: Fetched ${fetchedSubs.length} subscribers');
      list_subs.assignAll(fetchedSubs);
      print('SubscripersService: Updated list with ${list_subs.length} subscribers');
    } catch (e) {
      print('Error fetching subscribers: $e');
      // You might want to show a snackbar or handle error UI here
    }
  }

  Future<void> addSubsciper(Subscriper sub) async {
    try {
      final createdSub = await sub_repository.createSubscriper(sub);
      list_subs.add(createdSub);
    } catch (e) {
      print('Error adding subscriber: $e');
      rethrow;
    }
  }

  Future<void> deleteSubscriper(Subscriper sub) async {
    try {
      await sub_repository.destroySubscriper(sub.id);
      list_subs.remove(sub);
    } catch (e) {
      print('Error deleting subscriber: $e');
      rethrow;
    }
  }

  Future<void> editSubscriper(Subscriper sub) async {
    try {
      final updatedSub = await sub_repository.updateSubscriper(sub);
      final index = list_subs.indexWhere((s) => s.id == sub.id);
      if (index != -1) {
        list_subs[index] = updatedSub;
      } else {
        print('Subscriber ${sub.name} with id ${sub.id} not found in the list.');
      }
    } catch (e) {
      print('Error updating subscriber ${sub.name}: $e');
      rethrow;
    }
  }

  Subscriper? getSubscriberById(int id) {
    try {
      return list_subs.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
