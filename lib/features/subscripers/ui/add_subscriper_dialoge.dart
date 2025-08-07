import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:moalidaty1/features/subscripers/models/model.dart';
import 'package:moalidaty1/features/subscripers/services/service.dart';

class AddSubscriberDialoge extends StatelessWidget {
  AddSubscriberDialoge({super.key});
  final sub_service = Get.find<subscripersService>();
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
          child: Text("رجوع"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        ),
        ElevatedButton(
          onPressed: () {
            final Subscriper new_sub = Subscriper(
              name: namectrl.text,
              amber: int.parse(amberctrl.text),
              circuit_number:
                  circiut_numctrl.text == "" ? "0" : circiut_numctrl.text,
              phone: phonectrl.text == "" ? "077" : phonectrl.text,
            );
            sub_service.addSubsciper(new_sub);
            Navigator.pop(context);
          },
          child: Text("اضافة"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
}
