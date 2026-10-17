import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../models/receipt.dart';
import 'receipt_detail_sheet.dart';

/// One receipt as a transaction row: avatar, name, month • time, +amount.
class ReceiptTile extends StatelessWidget {
  final Receipt receipt;
  final bool dense;
  final bool showWorker;

  const ReceiptTile({super.key, required this.receipt, this.dense = false, this.showWorker = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = receipt;
    final meta = [
      r.label,
      if (dense) Fmt.date(r.dateReceived) else Fmt.time(r.dateReceived),
      if (showWorker) r.workerName ?? 'المدير',
    ].join(' • ');
    return InkWell(
      onTap: () => showReceiptDetail(r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: dense ? 9 : 11),
        child: Row(children: [
          NameAvatar(name: r.subscriberName, size: dense ? 40 : 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.subscriberName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary, fontSize: 14)),
              const SizedBox(height: 1),
              Text(meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: p.textMuted)),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('+${Fmt.number(r.amountPaid)}',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontWeight: FontWeight.w800, color: p.success, fontSize: 14)),
              Icon(Icons.arrow_upward_rounded, size: 14, color: p.success),
            ]),
            Text('${r.subscriberAmbers} أمبير', style: TextStyle(fontSize: 10.5, color: p.textMuted)),
          ]),
        ]),
      ),
    );
  }
}
