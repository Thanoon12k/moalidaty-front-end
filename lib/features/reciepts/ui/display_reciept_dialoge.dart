import 'package:flutter/material.dart';

class DisplayReceiptDialog extends StatelessWidget {
  final String imageUrl;

  const DisplayReceiptDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 120),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('WhatsApp'),
                  onPressed: () {
                    // TODO: Implement WhatsApp sharing
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  onPressed: () {
                    // TODO: Implement print functionality
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save'),
                  onPressed: () {
                    // TODO: Implement save to device
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
