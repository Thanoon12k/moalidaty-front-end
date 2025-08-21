import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/common_widgets/delete_dialoge.dart';
import 'package:moalidaty1/common_widgets/loading_indicator.dart';
import 'package:moalidaty1/features/subscripers/services/service.dart';
import 'package:moalidaty1/features/subscripers/ui/add_subscriper_dialoge.dart';
import 'package:moalidaty1/features/subscripers/ui/update_subscriper_dialoge.dart';

class SubscripersListPage extends StatelessWidget {
  const SubscripersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subsService = Get.put(subscripersService());
    return Scaffold(
      appBar: CustomAppBar(title: "قائمة المشتركين", font_size: 32),
      body: FutureBuilder(
        future: subsService.getSubscripers(),
        builder: (context, snapshot) {
          return Obx(() {
            if (subsService.list_subs.isEmpty) {
              return const Center(child: SimpleWaiting());
            }

            return ListView.separated(
              separatorBuilder: (_, _) => const Divider(thickness: 2),
              itemCount: subsService.list_subs.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final sub = subsService.list_subs[index];
                return Container(
                  padding: EdgeInsets.all(16),
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
                        radius: 28,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              sub.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الامبيرات: ${sub.amber}',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'رقم الجوزة: ${sub.circuit_number}',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الهاتف: ${sub.phone}',
                              style: const TextStyle(
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
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 32),
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
