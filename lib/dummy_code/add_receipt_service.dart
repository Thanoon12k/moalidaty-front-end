// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:moalidaty1/features/budgets/services/service_budget.dart';
// // import 'package:moalidaty1/features/reciepts/models/model.dart';
// // import 'package:moalidaty1/features/subscripers/models/model.dart';
// // import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
// // import 'package:moalidaty1/features/reciepts/services/service_recepts.dart';

// // class AddReceiptService extends GetxController {
// //   final _subscribersService = Get.find<SubscripersService>();
// //   final _receiptService = Get.find<RecieptServices>();
// //   final _budgetService = Get.find<BudgetService>();

// //   // Observable values
// //   final RxList<int> availableYears = <int>[].obs;
// //   final RxList<int> availableMonths = <int>[].obs;
// //   final Rx<Subscriper?> selectedSubscriber = Rx<Subscriper?>(null);
// //   final RxInt selectedYear = DateTime.now().year.obs;
// //   final RxInt selectedMonth = DateTime.now().month.obs;
// //   final RxDouble amberPrice = 0.0.obs;
// //   final RxDouble amountPaid = 0.0.obs;
// //   final RxString imagePath = RxString('');
 
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     initData();
// //   }

// //   void initData() {
// //     ttry {
// //       // Get unique years from budgets
// //       availableYears.value = _budgetService.budgets
// //           .map((b) => b.year)
// //           .toSet()
// //           .toList()
// //         ..sort();

// //       if (availableYears.isNotEmpty) {
// //         selectedYear.value = availableYears.last;
// //         updateAvailableMonths();
// //       }
// //     }  catch (e, stackTrace) {
//       print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
//       print(stackTrace);
//       print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
// //       print('Error initializing data: $e');
// //     }
// //   }

// //   void updateAvailableMonths() {
// //     availableMonths.value = _budgetService.budgets
// //         .where((b) => b.year == selectedYear.value)
// //         .map((b) => b.month)
// //         .toSet()
// //         .toList()
// //       ..sort();
    
// //     if (availableMonths.isNotEmpty && !availableMonths.contains(selectedMonth.value)) {
// //       selectedMonth.value = availableMonths.first;
// //     }
// //     updateAmberPrice();
// //   }

// //   void updateAmberPrice() {
// //     if (selectedSubscriber.value != null) {
// //       final budget = _budgetService.budgets.firstWhereOrNull(
// //         (b) => b.year == selectedYear.value && b.month == selectedMonth.value,
// //       );

// //       if (budget != null) {
// //         amberPrice.value = budget.amber_price;
// //       } else {
// //         amberPrice.value = 0.0;
// //         Get.snackbar(
// //           'تنبيه',
// //           'لا يوجد ميزانية للشهر والسنة المختارة',
// //           backgroundColor: Colors.orange,
// //           colorText: Colors.white,
// //         );
// //       }
// //     }
// //   }

// //   Future<void> submitForm() async {
// //     if (selectedSubscriber.value == null) return;

//     // ttry {
// //       final newReceipt = Reciept(
// //         date: DateTime.now(),
// //         subscriberId: selectedSubscriber.value!.id,
// //         amberPrice: amberPrice.value,
// //         amountPaid: amountPaid.value,
// //         year: selectedYear.value,
// //         month: selectedMonth.value,
// //         image: imagePath.value.isEmpty ? null : imagePath.value,
// //         subscriber: selectedSubscriber.value,
// //       );

// //       await _receiptService.addReciept(newReceipt);
// //       Get.back();
// //       Get.snackbar(
// //         'نجاح',
// //         'تم إضافة الوصل بنجاح',
// //         backgroundColor: Colors.green,
// //         colorText: Colors.white,
// //       );
//     // }  catch (e, stackTrace) {
//     //   print(" ❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ ");
//     //   print(stackTrace);
//     //   print(" ❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗❗");
// //       Get.snackbar(
// //         'خطأ',
// //         'حدث خطأ أثناء إضافة الوصل',
// //         backgroundColor: Colors.red,
// //         colorText: Colors.white,
// //       );
// //     }
// //   }
// // }