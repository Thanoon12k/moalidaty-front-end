import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../controllers/receipt_controller.dart';

/// قائمة الانتظار — receipts recorded offline, sent when online again.
class PendingReceiptsScreen extends StatelessWidget {
  const PendingReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ctrl = Get.find<ReceiptController>();

    Future<void> sync() async {
      final sent = await ctrl.syncPending();
      if (sent > 0) {
        showSnack('تم إرسال $sent إيصال');
      } else if (ctrl.pending.isNotEmpty) {
        showSnack('ما زال الاتصال غير متاح أو رُفضت بعض الإيصالات', error: true);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الانتظار')),
      body: Obx(() {
        final items = ctrl.pending;
        if (items.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: Icons.cloud_done_rounded,
              title: 'لا توجد إيصالات بانتظار الإرسال',
              subtitle: 'الإيصالات المسجّلة بدون إنترنت تظهر هنا وتُرسل تلقائياً عند عودة الاتصال',
            ),
          );
        }
        final total = items.fold(0.0, (s, x) => s + x.input.amountPaid);
        return ListView(padding: const EdgeInsets.all(16), children: [
          AppCard(
            child: Row(children: [
              IconTile(icon: Icons.cloud_upload_rounded, color: p.orange, background: p.orangeSoft),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${items.length} إيصال بانتظار الإرسال',
                      style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary)),
                  Text('بقيمة ${Fmt.money(total)}', style: TextStyle(color: p.textSecondary, fontSize: 12.5)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          LoadingButton(
            label: 'إرسال الآن',
            icon: Icons.sync_rounded,
            loading: ctrl.isSyncing.value,
            onPressed: sync,
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    NameAvatar(name: item.subscriberName, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.subscriberName,
                            style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary)),
                        Text('${item.input.label} • سُجّل ${Fmt.dateTime(item.createdAt)}',
                            style: TextStyle(fontSize: 11.5, color: p.textMuted)),
                      ]),
                    ),
                    Text(Fmt.money(item.input.amountPaid),
                        style: TextStyle(fontWeight: FontWeight.w800, color: p.textPrimary)),
                    IconButton(
                      tooltip: 'حذف من القائمة',
                      icon: Icon(Icons.delete_outline_rounded, color: p.danger),
                      onPressed: () async {
                        final ok = await confirmAction(
                          title: 'حذف من قائمة الانتظار',
                          message: 'لن يُرسل إيصال ${item.subscriberName} إلى الخادم. متابعة؟',
                          confirm: 'حذف',
                          destructive: true,
                        );
                        if (ok) await ctrl.removePending(item.localId);
                      },
                    ),
                  ]),
                  if (item.lastError != null) ...[
                    const SizedBox(height: 8),
                    Pill(
                      text: item.lastError!,
                      icon: Icons.error_outline_rounded,
                      color: p.danger,
                      background: p.dangerSoft,
                    ),
                  ],
                ]),
              ),
            ),
        ]);
      }),
    );
  }
}
