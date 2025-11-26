// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/constants/global_constants.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';

class AddSubscriberDialoge extends StatelessWidget {
  AddSubscriberDialoge({super.key});
  final sub_service = Get.find<SubscribersService>();
  final namectrl = TextEditingController();
  final amberctrl = TextEditingController();
  final circiut_numctrl = TextEditingController();
  final phonectrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("اضافة مشترك جديد"),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: namectrl,
              decoration: const InputDecoration(
                labelText: "الاسم",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amberctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "عدد الأمبيرات",

                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: circiut_numctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "رقم الجوزة",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phonectrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "رقم الهاتف",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: Text("رجوع"),
        ),
        ElevatedButton(
          onPressed: () {
            final Subscriper new_sub = Subscriper(
              generator: GlobalConstants.accountID!,
              name: namectrl.text,
              amber: int.parse(amberctrl.text),
              circuit_number: circiut_numctrl.text == ""
                  ? "0"
                  : circiut_numctrl.text,
              phone: phonectrl.text == "" ? "077" : phonectrl.text,
            );
            sub_service.addSubsciper(new_sub);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text("اضافة"),
        ),
      ],
    );
  }
}
