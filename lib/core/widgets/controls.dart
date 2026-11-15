import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Two-or-more option pill toggle ("Manage | Invest" in the reference).
class SegmentedToggle<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool expand;

  const SegmentedToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final children = [
      for (final (value, label) in options)
        _segment(context, p, value, label),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: expand ? children.map((c) => Expanded(child: c)).toList() : children,
      ),
    );
  }

  Widget _segment(BuildContext context, AppPalette p, T value, String label) {
    final on = value == selected;
    return Semantics(
      selected: on,
      button: true,
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? p.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: on ? Colors.white : p.textSecondary,
              fontWeight: on ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal row of selectable chips (months, quick amounts…).
class ChoiceChips<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  const ChoiceChips({super.key, required this.options, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (value, label) = options[i];
          final on = value == selected;
          return ChoiceChip(
            label: Text(label),
            selected: on,
            onSelected: (_) => onSelected(value),
            labelStyle: TextStyle(
              color: on ? Colors.white : p.textPrimary,
              fontWeight: on ? FontWeight.w700 : FontWeight.w500,
            ),
            selectedColor: p.accent,
            backgroundColor: p.surface,
            side: BorderSide(color: on ? p.accent : p.border),
          );
        },
      ),
    );
  }
}

/// Progress bar with the percentage in a pill at its start (budget cards).
class PercentBar extends StatelessWidget {
  final double value; // 0..1
  final Color? color;
  final double height;

  const PercentBar({super.key, required this.value, this.color, this.height = 18});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final v = value.clamp(0.0, 1.0);
    final c = color ?? p.success;
    final radius = BorderRadius.circular(height);
    // No LayoutBuilder: the bar must support intrinsic sizing (it sits in
    // IntrinsicHeight rows on the dashboard).
    return Semantics(
      label: 'نسبة التحصيل ${(v * 100).round()}%',
      child: SizedBox(
        height: height,
        child: Stack(children: [
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: radius))),
          if (v > 0)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: v),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (_, t, _) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: t,
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: height),
                      child: DecoratedBox(decoration: BoxDecoration(color: c, borderRadius: radius)),
                    ),
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            start: 3,
            top: 2,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.surface, borderRadius: radius),
              child: Text('${(v * 100).round()}%',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: p.textPrimary, height: 1.1)),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Round icon button used in screen headers (bell, menu…), with a badge.
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final int badge;
  final String tooltip;
  final Color? color;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.badge = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: badge > 0,
        label: Text('$badge'),
        backgroundColor: p.danger,
        child: Icon(icon, color: color ?? p.textPrimary, size: 24),
      ),
    );
  }
}
