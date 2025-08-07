import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/services/service.dart';
import 'package:moalidaty1/features/workers/models/model.dart';
import 'package:moalidaty1/features/workers/services/service.dart';

class deleteYesNoBox extends StatelessWidget {
  final Gen_Worker? worker;
  final Subscriper? subscriper;
  const deleteYesNoBox({Key? key, this.worker, this.subscriper})
    : super(key: key);
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
              final subsService = Get.find<subscripersService>();

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
