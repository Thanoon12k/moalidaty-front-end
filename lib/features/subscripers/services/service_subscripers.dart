import 'package:get/get.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/api/subscripers_api.dart';

class SubscripersService extends GetxService {
  final RxList<Subscriper> subscripers_list = <Subscriper>[].obs;
  final sub_repository = SubscriperAPI();

  @override
  Future<void> onInit() async {
    super.onInit();
    // ttry {
    await getSubscripers();
    // } catch (e, stackTrace) {

    //   rethrow;

    // }
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getSubscripers() async {
    // ttry {
    final fetchedSubs = await sub_repository.fetchSubscribers();
    subscripers_list.assignAll(fetchedSubs);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   // You might want to show a snackbar or handle error UI here
    // }
  }

  Future<void> addSubsciper(Subscriper sub) async {
    // ttry {
    final createdSub = await sub_repository.createSubscriper(sub);
    subscripers_list.add(createdSub);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> deleteSubscriper(Subscriper sub) async {
    // ttry {
    await sub_repository.destroySubscriper(sub.id);
    subscripers_list.remove(sub);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> editSubscriper(Subscriper sub) async {
    // ttry {
    final updatedSub = await sub_repository.updateSubscriper(sub);
    final index = subscripers_list.indexWhere((s) => s.id == sub.id);
    if (index != -1) {
      subscripers_list[index] = updatedSub;
    } else {}
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Subscriper? getSubscriberById(int id) {
    // ttry {
    return subscripers_list.firstWhere((s) => s.id == id);
    // } catch (e, stackTrace) {

    //   rethrow;
    //   return null;
    // }
  }
}
