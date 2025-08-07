import 'dart:math';

import 'package:get/get.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/repositories/repository.dart';

class subscripersService {
  final RxList<Subscriper> list_subs = <Subscriper>[].obs;
  final sub_repository = SubscriperRepository();
  Future<subscripersService> init() async {
    await getSubscripers();
    return this;
  }

  Future<void> getSubscripers() async {
    try {
      final fetched_subs = await sub_repository.fetchSubscribers();
      list_subs.assignAll(fetched_subs);
    } catch (e) {
      print('Error fetching subscribers: $e');
    }
  }

  Future<void> addSubsciper(Subscriper sub) async {
    sub_repository.createSubscriper(sub);
    list_subs.add(sub);
  }

  Future<void> deleteSubscriper(Subscriper sub) async {
    sub_repository.destroySubscriper(sub.id);
    list_subs.remove(sub);
  }

  Future<void> editSubscriper(Subscriper sub) async {
    try {
      await sub_repository.updateSubscriper(sub);
      final index = list_subs.indexWhere((s) => s.id == sub.id);
      if (index != -1) {
        list_subs[index] = sub;
      } else {
        print(
          'Subscriber ${sub.name} with id ${sub.id} not found in the list.',
        );
      }
    } catch (e) {
      print('❌ Error updating subscriper ${sub.name}: $e');
    }
  }
}
