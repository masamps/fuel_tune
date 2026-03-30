import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppleSectionCard extends StatelessWidget {
  const AppleSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.tintColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final effectiveTint = tintColor ?? theme.colorScheme.primary;
    final useBackdropBlur = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    final baseColor = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: useBackdropBlur ? 0.05 : 0.07)
        : Colors.white.withValues(alpha: useBackdropBlur ? 0.72 : 0.94);

    final overlayColor = effectiveTint.withValues(
      alpha: brightness == Brightness.dark
          ? (useBackdropBlur ? 0.08 : 0.06)
          : (useBackdropBlur ? 0.06 : 0.035),
    );

    final borderColor = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: useBackdropBlur ? 0.78 : 0.92);

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Color.alphaBlend(overlayColor, baseColor),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: brightness == Brightness.dark ? 0.22 : 0.05,
            ),
            blurRadius: useBackdropBlur ? 30 : 18,
            offset: Offset(0, useBackdropBlur ? 16 : 10),
          ),
        ],
      ),
      child: child,
    );

    if (!useBackdropBlur) {
      return RepaintBoundary(child: cardContent);
    }

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: cardContent,
        ),
      ),
    );
  }
}
