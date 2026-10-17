import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../utils/json.dart';

/// White rounded card with the soft shadow used across the app.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double radius;
  final BoxBorder? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.onLongPress,
    this.color,
    this.radius = 18,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final br = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: br,
        border: border,
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: br,
        child: InkWell(
          borderRadius: br,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Rounded-square icon on a soft tint (transaction / category tiles).
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  const IconTile({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.3)),
        child: Icon(icon, color: color, size: size * 0.5),
      );
}

/// Circle with the first letter of a name; the tint is stable per name.
class NameAvatar extends StatelessWidget {
  final String name;
  final double size;

  const NameAvatar({super.key, required this.name, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tints = [
      (p.primary, p.primarySoft),
      (p.purple, p.purpleSoft),
      (p.orange, p.orangeSoft),
      (p.success, p.successSoft),
      (p.accent, p.accentSoft),
    ];
    final (fg, bg) = tints[name.runes.fold(0, (a, r) => a + r) % tints.length];
    final letter = name.trim().characters1;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.32)),
      child: Text(
        letter.isEmpty ? '؟' : letter,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: size * 0.42, height: 1.1),
      ),
    );
  }
}

/// Small rounded label, e.g. "مدفوع" or "+3.4%".
class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  final IconData? icon;
  final double fontSize;

  const Pill({
    super.key,
    required this.text,
    required this.color,
    required this.background,
    this.icon,
    this.fontSize = 11.5,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: fontSize + 2, color: color), const SizedBox(width: 3)],
          Text(text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w700, height: 1.3)),
        ]),
      );
}

/// Section title with an optional trailing action ("عرض الكل").
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(4, 22, 4, 10),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: padding,
      child: Row(children: [
        Expanded(
          child: Text(title, style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: p.textPrimary)),
        ),
        ?trailing,
        if (action != null)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(action!, style: TextStyle(color: p.primary, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(color: p.primarySoft, shape: BoxShape.circle),
          child: Icon(icon, size: 40, color: p.primary),
        ),
        const SizedBox(height: 18),
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: p.textPrimary)),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(color: p.textSecondary)),
        ],
        if (actionLabel != null) ...[
          const SizedBox(height: 22),
          ElevatedButton.icon(onPressed: onAction, icon: const Icon(Icons.add_rounded), label: Text(actionLabel!)),
        ],
      ]),
    );
  }
}

/// Thin strip shown while the lists come from the device cache.
class OfflineBanner extends StatelessWidget {
  final String text;
  const OfflineBanner({super.key, this.text = 'غير متصل — تُعرض آخر بيانات محفوظة على الجهاز'});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: p.warningSoft, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(Icons.cloud_off_rounded, size: 18, color: p.warning),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: p.textPrimary, fontSize: 12.5))),
      ]),
    );
  }
}

/// Label + value pair used on detail screens ("PREV 17532.05").
class StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final CrossAxisAlignment align;

  const StatColumn({super.key, required this.value, required this.label, this.align = CrossAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(crossAxisAlignment: align, mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: p.textPrimary)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 11, color: p.textMuted)),
    ]);
  }
}
