import 'package:flutter/material.dart';
import 'package:moalidaty/common_widgets/delete_dialoge.dart';
import 'package:moalidaty/features/reciepts/ui/add_receipt_dialoge.dart';
import 'package:moalidaty/features/subscripers/models/model.dart';
import 'package:moalidaty/features/subscripers/services/service_subscripers.dart';
import 'package:moalidaty/features/subscripers/ui/update_subscriper_dialoge.dart';

void displaySubscriperDialoge(
  BuildContext context,
  SubscribersService subsService,
  Subscriper sub,
) {
  final unpaidBudgets =
      subsService.GetUnpaidsBudgetsForSubscriper(sub.id);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
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
                'تفاصيل المشترك',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 24),
              _buildDetailRow('الاسم', sub.name, Icons.person),
              _buildDetailRow(
                'الامبيرات',
                '${sub.amber} أمبير',
                Icons.flash_on,
              ),
              _buildDetailRow(
                'رقم الجوزة',
                sub.circuit_number,
                Icons.electric_bolt,
              ),
              if (sub.phone.isNotEmpty)
                _buildDetailRow('الهاتف', sub.phone, Icons.phone),
              SizedBox(height: 24),

              Text(
                'الفواتير غير المدفوعة:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              ...unpaidBudgets.map((budget) {
                final monthName =
                    budget.year_month; // assuming this is a string
                final amount = sub.amber * budget.amber_price;

                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  budget.year_month,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  '${sub.amber} أمبير',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (_) => AddReceiptDialoge(
                                deisinatedSubscriper: sub,
                                destination_month: budget.month,
                                destination_year: budget.year,
                                // 👈 Pass the month/budget here
                              ),
                            );
                          },
                          icon: Icon(Icons.receipt_long),
                          label: Text('إيصال جديد'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            textStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => UpdateSubscriperDialoge(sub: sub),
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
                          builder: (_) => DeleteYesNoBox(instance: sub),
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
