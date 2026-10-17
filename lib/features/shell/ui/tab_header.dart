import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/controls.dart';
import '../../receipts/controllers/receipt_controller.dart';
import '../../receipts/ui/pending_receipts_screen.dart';
import 'home_shell.dart';

/// Header of each tab: big title on the start side, bell + menu at the end
/// (as in the reference "Monthly Budgets ⊕   🔔 ☰").
class TabHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onAdd;
  final String addTooltip;

  const TabHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onAdd,
    this.addTooltip = 'إضافة',
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final receipts = Get.find<ReceiptController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 8, 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            if (subtitle != null)
              Text(subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: p.textSecondary)),
            Row(children: [
              Flexible(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: p.textPrimary, height: 1.25)),
              ),
              if (onAdd != null) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: addTooltip,
                  child: InkResponse(
                    onTap: onAdd,
                    radius: 22,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ]),
          ]),
        ),
        Obx(() => HeaderIconButton(
              tooltip: 'قائمة الانتظار',
              icon: Icons.notifications_none_rounded,
              badge: receipts.pending.length,
              onPressed: () => Get.to(() => const PendingReceiptsScreen()),
            )),
        const HeaderIconButton(tooltip: 'القائمة', icon: Icons.menu_rounded, onPressed: HomeShell.openMenu),
      ]),
    );
  }
}
