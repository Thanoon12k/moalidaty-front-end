import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/budgets/services/budget_service.dart';
import 'package:moalidaty1/features/reciepts/models/receipt_model.dart';
import 'package:moalidaty1/features/reciepts/api/receipt_api.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';

class RecieptServices extends GetxService {
  final RxList<Reciept> list_rcpts = <Reciept>[].obs;
  final RxList<Reciept> list_subs = <Reciept>[].obs;
  final RxList<Reciept> list_budg = <Reciept>[].obs;

  final recieptRepository = RecieptAPI();
  final sub_service = Get.find<SubscripersService>();
  final worker_Service = Get.find<WorkerService>();
  final budget_service = Get.find<BudgetService>();
  @override
  Future<void> onInit() async {
    super.onInit();
    // ttry {
    await getReciepts();
    // } catch (e, stackTrace) {

    //   rethrow;

    // }
  }

  Future<void> getReciepts() async {
    // ttry {
    final fetchedReciepts = await recieptRepository.fetchReciepts();
    // Enrich receipts with full subscriber and worker objects
    for (var receipt in fetchedReciepts) {
      // ttry {
      final subscriber = sub_service.getSubscriberById(receipt.subscriber);
      if (subscriber != null) {
        receipt.setSubscriber(subscriber);
      } else {}

      if (receipt.worker != null) {
        // ttry {
        final worker = worker_Service.getWorkerById(receipt.worker!);
        if (worker != null) {
          receipt.setWorker(worker);
        } else {}
        // } catch (workerError) {

        // }
      }
      //   } catch (e, stackTrace) {

      //     print(
      //       " ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗",
      //     );

      //   }
      // }
      fetchedReciepts.sort((a, b) => b.dateCreated!.compareTo(a.dateCreated!));
      list_rcpts.assignAll(fetchedReciepts);
      // } catch (e, stackTrace) {

      //   rethrow;

      //   rethrow;
      //   // You might want to show a snackbar or handle error UI here
      // }
    }
  }

  Future<void> addReciept(Reciept reciept) async {
    // ttry {
    final createdReceipt = await recieptRepository.createReciept(reciept);
    await getReciepts();
    // list_rcpts.add(createdReceipt);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> deleteReciept(Reciept reciept) async {
    // ttry {
    if (reciept.id == null) {
      throw Exception('Cannot delete receipt without an ID');
    }

    await recieptRepository.destroyReciept(reciept.id!);
    list_rcpts.remove(reciept);
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Future<void> editReciept(Reciept reciept) async {
    // ttry {
    final updatedReceipt = await recieptRepository.updateReciept(reciept);
    final index = list_rcpts.indexWhere((r) => r.id == reciept.id);
    if (index != -1) {
      list_rcpts[index] = updatedReceipt;
    } else {}
    // } catch (e, stackTrace) {

    //   rethrow;

    //   rethrow;
    // }
  }

  Reciept? getReceiptById(int id) {
    // ttry {
    return list_rcpts.firstWhere((r) => r.id == id);
    // } catch (e, stackTrace) {

    //   rethrow;
    //   return null;
    // }
  }

  List<Reciept> getReceiptsBySubscriber(int subscriber) {
    return list_rcpts.where((r) => r.subscriber == subscriber).toList();
  }

  List<Reciept> getReceiptsByYearMonth(int year, int month) {
    return list_rcpts.where((r) => r.year == year && r.month == month).toList();
  }
}
