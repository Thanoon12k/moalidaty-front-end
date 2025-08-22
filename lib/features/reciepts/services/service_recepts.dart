import 'package:get/get.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/reciepts/models/model.dart';
import 'package:moalidaty1/features/reciepts/repositories/repository.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';

class RecieptServices extends GetxService {
  final RxList<Reciept> list_rcpts = <Reciept>[].obs;
  final RxList<Reciept> list_subs = <Reciept>[].obs;
  final RxList<Reciept> list_budg = <Reciept>[].obs;

  final recieptRepository = RecieptRepository();
  final sub_service = Get.find<SubscripersService>();
  final worker_Service = Get.find<WorkerService>();
  final budget_service = Get.find<BudgetService>();
  @override
  Future<void> onInit() async {
    super.onInit();
    print('RecieptServices: onInit called now ');

    try {
      await getReciepts();
    } catch (e) {
      print('RecieptServices: Error in onInit: $e');
    }
  }

  Future<void> getReciepts() async {
    try {
      print('RecieptServices: Starting to fetch receipts');
      final fetchedReciepts = await recieptRepository.fetchReciepts();
      print('RecieptServices: Fetched ${fetchedReciepts.length} receipts');

      // Enrich receipts with full subscriber and worker objects
      for (var receipt in fetchedReciepts) {
        try {
          print(
            'Enriching receipt ${receipt.id} with subscriber ${receipt.subscriber}',
          );
          final subscriber = sub_service.getSubscriberById(receipt.subscriber);
          if (subscriber != null) {
            receipt.setSubscriber(subscriber);
            print('Set subscriber: ${subscriber.name}');
          } else {
            print('Subscriber ${receipt.subscriber} not found');
          }

          if (receipt.worker != null) {
            print(
              'Enriching receipt ${receipt.id} with worker ${receipt.worker}',
            );
            try {
              final worker = worker_Service.getWorkerById(receipt.worker!);
              if (worker != null) {
                receipt.setWorker(worker);
                print('Set worker: ${worker.name}');
              } else {
                print('Worker ${receipt.worker} not found');
              }
            } catch (workerError) {
              print('Error getting worker ${receipt.worker}: $workerError');
            }
          }
        } catch (e) {
          print('Error enriching receipt ${receipt.id}: $e');
        }
      }

      list_rcpts.assignAll(fetchedReciepts);
      print('RecieptServices: Updated list with ${list_rcpts.length} receipts');
    } catch (e) {
      print('Error fetching receipts: $e');
      // You might want to show a snackbar or handle error UI here
    }
  }

  Future<void> addReciept(Reciept reciept) async {
    try {
      final createdReceipt = await recieptRepository.createReciept(reciept);
      list_rcpts.add(createdReceipt);
    } catch (e) {
      print('Error adding receipt: $e');
      rethrow;
    }
  }

  Future<void> deleteReciept(Reciept reciept) async {
    try {
      await recieptRepository.destroyReciept(reciept.id);
      list_rcpts.remove(reciept);
    } catch (e) {
      print('Error deleting receipt: $e');
      rethrow;
    }
  }

  Future<void> editReciept(Reciept reciept) async {
    try {
      final updatedReceipt = await recieptRepository.updateReciept(reciept);
      final index = list_rcpts.indexWhere((r) => r.id == reciept.id);
      if (index != -1) {
        list_rcpts[index] = updatedReceipt;
      } else {
        print('Receipt with id ${reciept.id} not found in the list.');
      }
    } catch (e) {
      print('Error updating receipt ${reciept.id}: $e');
      rethrow;
    }
  }

  Reciept? getReceiptById(int id) {
    try {
      return list_rcpts.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Reciept> getReceiptsBySubscriber(int subscriber) {
    return list_rcpts.where((r) => r.subscriber == subscriber).toList();
  }

  List<Reciept> getReceiptsByYearMonth(int year, int month) {
    return list_rcpts.where((r) => r.year == year && r.month == month).toList();
  }
}
