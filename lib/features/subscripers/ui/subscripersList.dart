import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/common_widgets/delete_dialoge.dart';
import 'package:moalidaty1/common_widgets/loading_indicator.dart';
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/subscripers/ui/add_subscriper_dialoge.dart';
import 'package:moalidaty1/features/subscripers/ui/update_subscriper_dialoge.dart';

class SubscripersListPage extends StatelessWidget {
  const SubscripersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subsService = Get.find<SubscripersService>();
    return Scaffold(
      appBar: CustomAppBar(
        title: "قائمة المشتركين",
        font_size: 32,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث القائمة',
            onPressed: () async {
              await subsService
                  .getSubscripers(); // or any method that reloads data
              Get.snackbar(
                'تم التحديث',
                'تم تحميل المشتركين من جديد',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green[400],
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: subsService.getSubscripers(),
        builder: (context, snapshot) {
          return Obx(() {
            if (subsService.subscripers_list.isEmpty) {
              return const Center(child: SimpleWaiting());
            }

            return ListView.separated(
              separatorBuilder: (_, _) => const Divider(thickness: 2),
              itemCount: subsService.subscripers_list.length,
              padding: EdgeInsets.all(15),
              itemBuilder: (context, index) {
                final sub = subsService.subscripers_list[index];
                return Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red[300],
                        radius: 27,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              sub.name,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'الامبيرات: ${sub.amber}',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'رقم الجوزة: ${sub.circuit_number}',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'الهاتف: ${sub.phone}',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => deleteYesNoBox(subscriper: sub),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => UpdateSubscriperDialoge(sub: sub),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          });
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.add, size: 32),
            label: const Text(
              'إضافة مشترك جديد',
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
              // اضافة مشترك
              showDialog(
                context: context,
                builder: (_) => AddSubscriberDialoge(),
              );
            },
          ),
        ),
      ),
    );
  }
}
