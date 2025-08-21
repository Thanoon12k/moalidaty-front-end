import 'package:get/get.dart';
import 'package:moalidaty1/features/reciepts/models/model.dart';
import 'package:moalidaty1/features/reciepts/repositories/repository.dart';

class RecieptServices {
  final RxList<Reciept> list_rcpts = <Reciept>[].obs;
  final recieptRepository = RecieptRepository();

  Future<RecieptServices> init() async {
    print("recipt init successsfully now ");

    await getReciepts();
    return this;
  }

  Future<void> getReciepts() async {
    try {
      print('try to  fetching reciepts: ');
      final fetchedReciepts = await recieptRepository.fetchReciepts();
      list_rcpts.assignAll(fetchedReciepts);
    } catch (e) {
      print('Error fetching reciepts: $e');
    }
  }

  Future<void> addReciept(Reciept reciept) async {
    await recieptRepository.createReciept(reciept);
    list_rcpts.add(reciept);
  }

  Future<void> deleteReciept(Reciept reciept) async {
    await recieptRepository.destroyReciept(reciept.id);
    list_rcpts.remove(reciept);
  }

  Future<void> editReciept(Reciept reciept) async {
    try {
      await recieptRepository.updateReciept(reciept);
      final index = list_rcpts.indexWhere((r) => r.id == reciept.id);
      if (index != -1) {
        list_rcpts[index] = reciept;
      } else {
        print('Reciept with id ${reciept.id} not found in the list.');
      }
    } catch (e) {
      print('❌ Error updating reciept ${reciept.id}: $e');
    }
  }
}
