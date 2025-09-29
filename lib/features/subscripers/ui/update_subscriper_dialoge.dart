import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';

class UpdateSubscriperDialoge extends StatefulWidget {
  final Subscriper sub;

  const UpdateSubscriperDialoge({super.key, required this.sub});

  @override
  State<UpdateSubscriperDialoge> createState() =>
      _UpdateSubscriperDialogeState();
}

class _UpdateSubscriperDialogeState extends State<UpdateSubscriperDialoge> {
  late TextEditingController namectrl;
  late TextEditingController amberctrl;
  late TextEditingController circiut_numctrl;
  late TextEditingController phonectrl;

  final sub_service = Get.find<SubscribersService>();

  @override
  void initState() {
    super.initState();
    namectrl = TextEditingController(text: widget.sub.name);
    amberctrl = TextEditingController(text: "${widget.sub.amber}");
    circiut_numctrl = TextEditingController(text: widget.sub.circuit_number);
    phonectrl = TextEditingController(text: widget.sub.phone);
  }

  @override
  void dispose() {
    namectrl.dispose();
    amberctrl.dispose();
    circiut_numctrl.dispose();
    phonectrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("تعديل بيانات المشترك"),
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
              decoration: const InputDecoration(
                labelText: "عدد الأمبيرات",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: circiut_numctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "رقم الجوزة",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phonectrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
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
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          child: const Text("رجوع"),
        ),
        ElevatedButton(
          onPressed: () {
            final Subscriper editedSub = Subscriper(
              id: widget.sub.id,
              name: namectrl.text,
              amber: int.parse(amberctrl.text),
              circuit_number: circiut_numctrl.text,
              phone: phonectrl.text,
            );

            sub_service.editSubscriper(editedSub);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("تحديث"),
        ),
      ],
    );
  }
}
