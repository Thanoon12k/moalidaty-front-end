import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/app_error.dart';
import '../theme/app_palette.dart';

void showSnack(String message, {bool error = false, IconData? icon}) {
  final ctx = Get.context;
  if (ctx == null) return;
  final p = ctx.palette;
  ScaffoldMessenger.of(ctx)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon ?? (error ? Icons.error_outline_rounded : Icons.check_circle_rounded),
            color: error ? p.danger : p.fab, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
    ));
}

/// Runs [action] and shows its error as a snackbar. Returns false on error.
Future<bool> guard(Future<void> Function() action, {String? success}) async {
  try {
    await action();
    if (success != null) showSnack(success);
    return true;
  } catch (e) {
    showSnack(describeError(e), error: true);
    return false;
  }
}

Future<bool> confirmAction({
  required String title,
  required String message,
  String confirm = 'تأكيد',
  bool destructive = false,
}) async {
  final ctx = Get.context!;
  final p = ctx.palette;
  final ok = await showDialog<bool>(
    context: ctx,
    builder: (c) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: destructive ? p.danger : p.primary,
            minimumSize: const Size(110, 44),
          ),
          onPressed: () => Navigator.pop(c, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Primary button with a spinner while [loading].
class LoadingButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const LoadingButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: color == null ? null : ElevatedButton.styleFrom(backgroundColor: color),
          onPressed: loading ? null : onPressed,
          child: loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Text(label),
                ]),
        ),
      );
}

/// Bottom sheet scaffold used by every form.
Future<T?> showFormSheet<T>(Widget child) {
  return showModalBottomSheet<T>(
    context: Get.context!,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: child,
    ),
  );
}

/// Title row inside form sheets.
class SheetTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SheetTitle(this.title, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(children: [
        Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: p.textPrimary)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(color: p.textSecondary, fontSize: 12.5)),
        ],
      ]),
    );
  }
}

/// Small grey label above an input (as in the reference forms).
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 4, bottom: 6, top: 4),
        child: Text(text, style: TextStyle(fontSize: 12, color: context.palette.textSecondary, fontWeight: FontWeight.w600)),
      );
}
