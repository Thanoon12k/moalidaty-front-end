import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moalidaty1/common_widgets/appbar.dart';
import 'package:moalidaty1/common_widgets/loading_indicator.dart';
import 'package:moalidaty1/features/reciepts/models/model.dart';
import 'package:moalidaty1/features/reciepts/services/service.dart';
import 'package:moalidaty1/features/reciepts/ui/display_reciept_dialoge.dart';

class RecieptsListPage extends StatelessWidget {
  final recieptServices = Get.put(RecieptServices());

  RecieptsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'قائمة الإيصالات', font_size: 30),
      body: Obx(() {
       
        print(
          "recipt lists ----------------------------- ${recieptServices.list_rcpts}",
        );

        if (recieptServices.list_rcpts.isEmpty) {
          return const SimpleWaiting();
        }

        return ListView.builder(
          itemCount: recieptServices.list_rcpts.length,
          itemBuilder: (context, index) {
            final Reciept reciept = recieptServices.list_rcpts[index];
            return ListTile(
              leading:
                  reciept.image != null
                      ? Image.network(
                        reciept.image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                      : const Icon(Icons.receipt_long, size: 50),
              title: Text(reciept.subscriberName),
              trailing: IconButton(
                icon: const Icon(Icons.remove_red_eye),
                onPressed: () => DisplayReceiptDialog(imageUrl: ""),
              ),
            );
          },
        );
      }),
    );
  }
}
