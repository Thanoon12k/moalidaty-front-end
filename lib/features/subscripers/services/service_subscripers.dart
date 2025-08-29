import 'package:get/get.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/repositories/repository.dart';

class SubscripersService extends GetxService {
  final RxList<Subscriper> subscripers_list = <Subscriper>[].obs;
  final sub_repository = SubscriperRepository();

  @override
  Future<void> onInit() async {
    print('SubscripersService: onInit called');

    super.onInit();
    // ttry {
    await getSubscripers();
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   print('SubscripersService: Error in onInit: $e');
    // }
  }

  @override
  void onClose() {
    super.onClose();
    print('SubscripersService: onClose called');
  }

  Future<void> getSubscripers() async {
    // ttry {
    print('SubscripersService: Starting to fetch subscribers');
    final fetchedSubs = await sub_repository.fetchSubscribers();
    print('SubscripersService: Fetched ${fetchedSubs.length} subscribers');
    subscripers_list.assignAll(fetchedSubs);
    print(
      'SubscripersService: Updated list with ${subscripers_list.length} subscribers',
    );
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   print('Error fetching subscribers: $e');
    //   // You might want to show a snackbar or handle error UI here
    // }
  }

  Future<void> addSubsciper(Subscriper sub) async {
    // ttry {
    final createdSub = await sub_repository.createSubscriper(sub);
    subscripers_list.add(createdSub);
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   print('Error adding subscriber: $e');
    //   rethrow;
    // }
  }

  Future<void> deleteSubscriper(Subscriper sub) async {
    // ttry {
    await sub_repository.destroySubscriper(sub.id);
    subscripers_list.remove(sub);
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   print('Error deleting subscriber: $e');
    //   rethrow;
    // }
  }

  Future<void> editSubscriper(Subscriper sub) async {
    // ttry {
    final updatedSub = await sub_repository.updateSubscriper(sub);
    final index = subscripers_list.indexWhere((s) => s.id == sub.id);
    if (index != -1) {
      subscripers_list[index] = updatedSub;
    } else {
      print('Subscriber ${sub.name} with id ${sub.id} not found in the list.');
    }
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   print('Error updating subscriber ${sub.name}: $e');
    //   rethrow;
    // }
  }

  Subscriper? getSubscriberById(int id) {
    // ttry {
    return subscripers_list.firstWhere((s) => s.id == id);
    // } catch (e, stackTrace) {
    //   print('Error is: (( $e ))');
    //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
    //   print(stackTrace);
    //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
    //   rethrow;
    //   return null;
    // }
  }
}
