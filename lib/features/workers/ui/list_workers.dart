import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/common_widgets/delete_dialoge.dart';
import 'package:moalidaty1/common_widgets/loading_indicator.dart';
import 'package:moalidaty1/constants/global_constants.dart';
import 'package:moalidaty1/features/workers/ui/add_worker.dart';
import 'package:moalidaty1/features/workers/ui/update_worker.dart';
import '../services/service_worker.dart';

class WorkersListPage extends StatelessWidget {
  const WorkersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workerService = Get.find<WorkerService>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: "المشغلون",
        font_size: 28,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'البحث',
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'refresh') {
                await workerService.getWorkers();
                Get.snackbar(
                  'تم التحديث',
                  'تم تحميل المشغلين من جديد',
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
        if (workerService.workersList.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildHeaderStats(workerService.workersList.length),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await workerService.getWorkers();
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: GlobalConstants.scaleTo(16),
                    vertical: GlobalConstants.scaleTo(8),
                  ),
                  itemCount: workerService.workersList.length,
                  itemBuilder: (context, index) {
                    final worker = workerService.workersList[index];
                    return _buildWorkerCard(context, worker, index);
                  },
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(context: context, builder: (_) => AddWorkerDialog());
        },
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
        icon: Icon(Icons.person_add),
        label: Text('إضافة مشغل', style: TextStyle(fontSize: 16)),
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
                builder: (_) => AddWorkerDialog(),
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

  Widget _buildHeaderStats(int count) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[300]!, Colors.red[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.people, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي المشغلين',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, dynamic worker, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showWorkerDetails(context, worker);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildWorkerAvatar(worker.name, index),
                SizedBox(width: 16),
                Expanded(child: _buildWorkerInfo(worker)),
                _buildActionButtons(context, worker),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerAvatar(String name, int index) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[300]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '؟',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerInfo(dynamic worker) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          worker.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 6),
        if (worker.phone != null)
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.green[600]),
              SizedBox(width: 6),
              Text(
                worker.phone,
                style: TextStyle(fontSize: 14, color: Colors.green[600]),
              ),
            ],
          ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.blue[600]),
            SizedBox(width: 6),
            Text(
              _formatDate(worker.date_created!),
              style: TextStyle(fontSize: 14, color: Colors.blue[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic worker) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.edit, color: Colors.blue[600], size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => UpdateWorkerDialog(worker: worker),
              );
            },
            tooltip: 'تعديل',
          ),
        ),
        SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.delete, color: Colors.red[600], size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => deleteYesNoBox(worker: worker),
              );
            },
            tooltip: 'حذف',
          ),
        ),
      ],
    );
  }

  void _showWorkerDetails(BuildContext context, dynamic worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'تفاصيل المشغل',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 24),
                _buildDetailRow('الاسم', worker.name, Icons.person),
                _buildDetailRow(
                  'الهاتف',
                  worker.phone ?? 'غير محدد',
                  Icons.phone,
                ),
                _buildDetailRow(
                  'تاريخ بدء العمل',
                  _formatDate(worker.date_created!),
                  Icons.calendar_today,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => UpdateWorkerDialog(worker: worker),
                          );
                        },
                        icon: Icon(Icons.edit),
                        label: Text('تعديل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => deleteYesNoBox(worker: worker),
                          );
                        },
                        icon: Icon(Icons.delete),
                        label: Text('حذف'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[600]),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
