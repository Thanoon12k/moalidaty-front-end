import 'package:flutter/material.dart';
import 'package:moalidaty/features/reciepts/models/receipt_model.dart';

class DisplayReceiptDialog extends StatelessWidget {
  final Reciept receipt;

  const DisplayReceiptDialog({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.receipt_long, size: 32, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Text(
                    'تفاصيل الإيصال',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Receipt Details
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info
                      _buildInfoRow('رقم الإيصال:', '${receipt.id}'),
                      _buildInfoRow(
                        'التاريخ:',
                        _formatDate(receipt.dateReceived ?? DateTime.now()),
                      ),
                      _buildInfoRow('المشترك:', receipt.subscriberName),
                      _buildInfoRow(
                        'رقم الجوزة:',
                        receipt.subscriperCircuitNummber,
                      ),
                      if (receipt.worker != null)
                        _buildInfoRow('العامل:', receipt.workerName),
                      _buildInfoRow('الشهر:', '${receipt.month}'),
                      _buildInfoRow('السنة:', '${receipt.year}'),
                      _buildInfoRow(
                        'سعر الامبير:',
                        '${(receipt.amberPrice)} د.ع',
                      ),
                      _buildInfoRow(
                        'المبلغ المدفوع:',
                        '${receipt.amountPaid} د.ع',
                      ),
                      if (receipt.yearMonthSubscriberId != null)
                        _buildInfoRow(
                          'معرف الشهر-السنة:',
                          receipt.yearMonthSubscriberId!,
                        ),

                      const SizedBox(height: 24),

                      // Receipt Image
                      if (receipt.imageUrl != null && receipt.imageUrl != '')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'صورة الإيصال:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    receipt.imageUrl ?? '',
                                    height: 200,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 120,
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    onPressed: () {
                    
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة'),
                    onPressed: () {
                     
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save_alt),
                    label: const Text('حفظ'),
                    onPressed: () {
                    
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
