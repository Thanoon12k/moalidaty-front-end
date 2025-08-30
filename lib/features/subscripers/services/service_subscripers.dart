import 'package:get/get.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/api/subscripers_api.dart';

class SubscribersService extends GetxService {
  final RxList<Subscriper> subscribersList = <Subscriper>[].obs;
  final subApi = SubscriperAPI();

  @override
  Future<void> onInit() async {
    super.onInit();
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
    final fetchedSubs = await subApi.fetchSubscribers();
    subscribersList.assignAll(fetchedSubs);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   // You might want to show a snackbar or handle error UI here
    // }
  }

  Future<void> addSubsciper(Subscriper sub) async {
    final createdSub = await subApi.createSubscriper(sub);
    subscribersList.add(createdSub);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> deleteSubscriper(Subscriper sub) async {
    await subApi.destroySubscriper(sub.id);
    subscribersList.remove(sub);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> editSubscriper(Subscriper sub) async {
    final updatedSub = await subApi.updateSubscriper(sub);
    final index = subscribersList.indexWhere((s) => s.id == sub.id);
    if (index != -1) {
      subscribersList[index] = updatedSub;
    } else {}
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Subscriper? getSubscriberById(int id) {
    return subscribersList.firstWhere((s) => s.id == id);
    // } catch (e, stackTrace) {

    //   rethrow;
    //   return null;
    // }
  }
}
