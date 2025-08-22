import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:moalidaty1/features/workers/services/service_worker.dart';

class deleteYesNoBox extends StatelessWidget {
  final Gen_Worker? worker;
  final Subscriper? subscriper;
  const deleteYesNoBox({super.key, this.worker, this.subscriper});
  @override
  Widget build(BuildContext context) {
    final objectToDelete = worker ?? subscriper;
    final String title = objectToDelete is Gen_Worker ? 'المشغل' : ' المشترك';

    return AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: Text('هل أنت متأكد أنك تريد حذف هذا $title؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('لا'),
        ),
        TextButton(
          onPressed: () {
            if (worker != null) {
              final workerService = Get.find<WorkerService>();
              workerService.removeWorker(worker!);
            } else if (subscriper != null) {
              final subsService = Get.find<SubscripersService>();

              subsService.deleteSubscriper(subscriper!);
            }
            Navigator.pop(context);
          },
          child: const Text('نعم'),
        ),
      ],
    );
  }
}

class AlreteingDialoge extends StatelessWidget {
  final String errorMessage;
  const AlreteingDialoge({
    super.key,
    this.errorMessage = "العملية فشلت !! تحقق من الاتصال بالانترنت",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.yellow, size: 28),
          const SizedBox(width: 8),
          const Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(errorMessage, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('حسناً', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
