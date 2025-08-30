import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/common_widgets/delete_dialoge.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/subscripers/ui/add_subscriper_dialoge.dart';
import 'package:moalidaty1/features/subscripers/ui/update_subscriper_dialoge.dart';

class SubscripersListPage extends StatelessWidget {
  const SubscripersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subsService = Get.find<SubscribersService>();
    return Scaffold(
      appBar: CustomAppBar(
        title: "قائمة المشتركين",
        font_size: 32,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'البحث',
            onPressed: () {
              subsService.showSearch.value = !subsService.showSearch.value;
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'refresh') {
                await subsService.getSubscripers();
                Get.snackbar(
                  'تم التحديث',
                  'تم تحميل المشتركين من جديد',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green[400],
                  colorText: Colors.white,
                  duration: Duration(seconds: 2),
                );
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.grey[700]),
                        SizedBox(width: 12),
                        Text('تحديث القائمة'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Obx(() {
        if (subsService.filteredSubscripers.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            if (subsService.showSearch.value) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مشترك...',
                    hintTextDirection: TextDirection.rtl,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon:
                        subsService.searchQuery.value.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed:
                                  () => subsService.searchQuery.value = '',
                              tooltip: 'مسح البحث',
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    subsService.searchQuery.value = value;
                  },
                ),
              ),
            ],

            Expanded(
              child: ListView.separated(
                separatorBuilder: (_, _) => const Divider(thickness: 2),
                itemCount: subsService.filteredSubscripers.length,
                padding: EdgeInsets.all(15),
                itemBuilder: (context, index) {
                  final sub = subsService.filteredSubscripers[index];

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
              ),
            ),
          ],
        );
      }),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'لا يوجد مشغلون',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'ابدأ بإضافة أول مشغل',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: Get.context!,
                builder: (_) => AddSubscriberDialoge(),
              );
            },
            icon: Icon(Icons.add),
            label: Text('إضافة مشغل جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
