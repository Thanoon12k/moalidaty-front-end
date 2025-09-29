import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/common_widgets/delete_dialoge.dart';
import 'package:moalidaty/features/workers/models/model.dart';
import 'package:moalidaty/features/workers/ui/add_worker.dart';
import 'package:moalidaty/features/workers/ui/update_worker.dart';

Widget buildEmptyState() {
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
          child: Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
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

Widget buildHeaderStats(int count) {
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

Widget buildWorkerCard(BuildContext context, Gen_Worker worker, int index) {
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
              buildWorkerAvatar(worker.name, index),
              SizedBox(width: 16),
              Expanded(child: buildWorkerInfo(worker)),
              buildActionButtons(context, worker),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildWorkerAvatar(String name, int index) {
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

Widget buildWorkerInfo(Gen_Worker worker) {
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
              worker.phone!,
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
            formatDate(worker.date_created!),
            style: TextStyle(fontSize: 14, color: Colors.blue[600]),
          ),
        ],
      ),
    ],
  );
}

Widget buildActionButtons(BuildContext context, Gen_Worker worker) {
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
              builder: (_) => DeleteYesNoBox(instance: worker),
            );
          },
          tooltip: 'حذف',
        ),
      ),
    ],
  );
}

void _showWorkerDetails(BuildContext context, Gen_Worker worker) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
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
          buildDetailRow('الاسم', worker.name, Icons.person),
          buildDetailRow('الهاتف', worker.phone ?? 'غير محدد', Icons.phone),
          buildDetailRow(
            'تاريخ بدء العمل',
            formatDate(worker.date_created!),
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
                      builder: (_) => DeleteYesNoBox(instance: worker),
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

Widget buildDetailRow(String label, String value, IconData icon) {
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

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
