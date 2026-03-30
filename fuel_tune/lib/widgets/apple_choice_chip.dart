import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppleChoiceChip extends StatelessWidget {
  const AppleChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.tintColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final effectiveTint = tintColor ?? colorScheme.primary;

    final backgroundColor = selected
        ? effectiveTint.withValues(
            alpha: brightness == Brightness.dark ? 0.24 : 0.16,
          )
        : (brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7));

    final borderColor = selected
        ? effectiveTint.withValues(
            alpha: brightness == Brightness.dark ? 0.42 : 0.22,
          )
        : (brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05));

    final textColor =
        selected ? colorScheme.onSurface : colorScheme.onSurfaceVariant;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
