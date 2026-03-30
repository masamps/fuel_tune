import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ApplePageLayout extends StatelessWidget {
  const ApplePageLayout({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.accentColor,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Color? accentColor;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final highlight = accentColor ?? colorScheme.primary;
    final showAmbientGlows = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final background = theme.scaffoldBackgroundColor;
    final tertiary = colorScheme.tertiary.withValues(
      alpha: showAmbientGlows
          ? (theme.brightness == Brightness.dark ? 0.12 : 0.08)
          : (theme.brightness == Brightness.dark ? 0.08 : 0.04),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            background,
            Color.alphaBlend(
              highlight.withValues(
                alpha: showAmbientGlows
                    ? (theme.brightness == Brightness.dark ? 0.05 : 0.025)
                    : (theme.brightness == Brightness.dark ? 0.025 : 0.012),
              ),
              background,
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (showAmbientGlows)
            Positioned(
              top: -70,
              right: -30,
              child: _AmbientGlow(
                color: highlight.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.2 : 0.14,
                ),
                size: 190,
              ),
            ),
          if (showAmbientGlows)
            Positioned(
              top: 140,
              left: -90,
              child: _AmbientGlow(color: tertiary, size: 220),
            ),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 132),
              cacheExtent: 600,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FUEL TUNE',
                            style: theme.textTheme.labelMedium?.copyWith(
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.2,
                              height: 0.98,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.38,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 12),
                      trailing!,
                    ],
                  ],
                ),
                const SizedBox(height: 26),
                ..._withSpacing(children),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> children) {
    if (children.isEmpty) {
      return const [];
    }

    final spaced = <Widget>[];

    for (var index = 0; index < children.length; index++) {
      spaced.add(children[index]);
      if (index != children.length - 1) {
        spaced.add(const SizedBox(height: 14));
      }
    }

    return spaced;
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
