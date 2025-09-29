import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/appbar.dart';
import 'package:moalidaty/common_widgets/delete_dialoge.dart';
import 'package:moalidaty/common_widgets/loading_indicator.dart';
import 'package:moalidaty/features/reciepts/models/receipt_model.dart';
import 'package:moalidaty/features/reciepts/services/service_recepts.dart';
import 'package:moalidaty/features/reciepts/ui/add_receipt_dialoge.dart';
import 'package:moalidaty/features/reciepts/ui/display_reciept_dialoge.dart';

class RecieptsListPage extends StatelessWidget {
  final recieptServices = Get.find<ReceiptServices>();

  RecieptsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'قائمة الإيصالات',
        font_size: 30,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث القائمة',
            onPressed: () async {
              await recieptServices
                  .getReciepts(); // or any method that reloads data
              Get.snackbar(
                'تم التحديث',
                'تم تحميل الإيصالات من جديد',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green[400],
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),

      body: Obx(() {
        // Show loading indicator while fetching data
        if (recieptServices.receiptsList.isEmpty) {
          return const Center(child: GeneratorLoadingIndicator());
        }

        return ListView.builder(
          itemCount: recieptServices.receiptsList.length,
          itemBuilder: (context, index) {
            final Reciept reciept = recieptServices.receiptsList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: reciept.imageUrl != null && reciept.imageUrl != ''
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            reciept.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.receipt_long,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                          ),
                        )
                      : const Icon(
                          Icons.receipt_long,
                          size: 30,
                          color: Colors.grey,
                        ),
                ),
                title: Text(
                  reciept.subscriberName.isNotEmpty
                      ? reciept.subscriberName
                      : 'مشترك رقم ${reciept.subscriber}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'المبلغ: ${reciept.amountPaid} د.ع',
                      style: const TextStyle(fontSize: 22, color: Colors.blue),
                    ),
                    Text(
                      ' الشهر: ${reciept.month}/${reciept.year} |   تاريخ الاستلام: ${_formatDate(reciept.dateReceived ?? reciept.dateCreated!)}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              DisplayReceiptDialog(receipt: reciept),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => DeleteYesNoBox(instance: reciept),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 32),
            label: const Text(
              'إضافة ايصال جديد',
              style: TextStyle(fontSize: 24),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // اضافة ايصال جديد
              showDialog(context: context, builder: (_) => AddReceiptDialoge());
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
