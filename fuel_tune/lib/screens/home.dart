import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tune/l10n/app_language_scope.dart';
import 'package:fuel_tune/l10n/language_controller.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';
import 'package:fuel_tune/screens/premium/premium_insights_page.dart';
import 'package:fuel_tune/theme/theme_controller.dart';

import 'home/autonomy_page.dart';
import 'home/mixture_page.dart';
import 'home/save_page.dart';
import 'home/settings_page.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.themeController,
    required this.languageController,
  });

  final ThemeController themeController;
  final LanguageController languageController;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  _HomeTab _selectedTab = _HomeTab.mixture;
  final LocalPreferencesRepository _preferencesRepository =
      LocalPreferencesRepository();
  late final ValueNotifier<int> _appStateVersion = ValueNotifier(0);
  late final ValueNotifier<double> _pageProgress = ValueNotifier(0);
  late final PageController _pageController = PageController(initialPage: 0);
  bool _isProUnlocked = false;

  late final Map<_HomeTab, Widget> _pageByTab = {
    _HomeTab.mixture: const MixturePage(key: PageStorageKey('mixturePage')),
    _HomeTab.consumption: ConsumptionPage(
      key: const PageStorageKey('consumptionPage'),
      appStateVersion: _appStateVersion,
    ),
    _HomeTab.history: HistoryPage(
      key: const PageStorageKey('historyPage'),
      appStateVersion: _appStateVersion,
    ),
    _HomeTab.premium: PremiumInsightsPage(
      key: const PageStorageKey('premiumPage'),
      appStateVersion: _appStateVersion,
    ),
    _HomeTab.settings: SettingsPage(
      key: const PageStorageKey('settingsPage'),
      themeController: widget.themeController,
      languageController: widget.languageController,
      appStateVersion: _appStateVersion,
    ),
  };

  @override
  void initState() {
    super.initState();
    _appStateVersion.addListener(_handleAppStateChanged);
    _pageController.addListener(_handlePageScroll);
    _loadProState();
  }

  List<_HomeTab> get _visibleTabOrder => [
        _HomeTab.mixture,
        _HomeTab.consumption,
        _HomeTab.history,
        if (_isProUnlocked) _HomeTab.premium,
        _HomeTab.settings,
      ];

  int get _selectedIndex {
    final index = _visibleTabOrder.indexOf(_selectedTab);
    return index >= 0 ? index : 0;
  }

  void _handleAppStateChanged() {
    _loadProState();
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients) {
      return;
    }

    final page = _pageController.page;

    if (page == null || (_pageProgress.value - page).abs() < 0.001) {
      return;
    }

    _pageProgress.value = page;
  }

  Future<void> _loadProState() async {
    final isProUnlocked = await _preferencesRepository.loadIsProUnlocked();

    if (!mounted) {
      return;
    }

    setState(() {
      _isProUnlocked = isProUnlocked;

      if (!_visibleTabOrder.contains(_selectedTab)) {
        _selectedTab = _HomeTab.mixture;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      _pageController.jumpToPage(_selectedIndex);
      _pageProgress.value = _selectedIndex.toDouble();
    });
  }

  void _onItemTapped(int index) {
    final targetTab = _visibleTabOrder[index];

    if (_selectedTab == targetTab) {
      return;
    }

    setState(() {
      _selectedTab = targetTab;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _onBottomBarDragUpdate(double deltaX) {
    if (!_pageController.hasClients) {
      return;
    }

    final position = _pageController.position;
    final targetPixels = (position.pixels + deltaX).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    position.jumpTo(targetPixels.toDouble());
  }

  void _onBottomBarDragEnd(double velocityX) {
    _settleBottomBarDrag(velocityX);
  }

  void _onBottomBarDragCancel() {
    _settleBottomBarDrag(0);
  }

  void _settleBottomBarDrag(double velocityX) {
    if (!_pageController.hasClients) {
      return;
    }

    final rawPage = _pageController.page ?? _selectedIndex.toDouble();
    var targetPage = rawPage.round();

    if (velocityX.abs() > 260) {
      targetPage = velocityX < 0 ? rawPage.ceil() : rawPage.floor();
    }

    targetPage = targetPage.clamp(0, _visibleTabOrder.length - 1);
    final targetTab = _visibleTabOrder[targetPage];

    if (_selectedTab != targetTab && mounted) {
      setState(() {
        _selectedTab = targetTab;
      });
    }

    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _appStateVersion.removeListener(_handleAppStateChanged);
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    _appStateVersion.dispose();
    _pageProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final tabs = _buildNavItems(context);

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          final nextTab = _visibleTabOrder[index];

          if (_selectedTab == nextTab) {
            return;
          }

          setState(() {
            _selectedTab = nextTab;
          });
        },
        children: _visibleTabOrder.map((tab) => _pageByTab[tab]!).toList(),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: ValueListenableBuilder<double>(
          valueListenable: _pageProgress,
          builder: (context, pageProgress, _) {
            return SizedBox(
              height: 80,
              child: _FuelTuneBottomBar(
                items: tabs,
                selectedIndex: _selectedIndex,
                pageProgress: pageProgress,
                onTap: _onItemTapped,
                onHorizontalDragUpdate: _onBottomBarDragUpdate,
                onHorizontalDragEnd: _onBottomBarDragEnd,
                onHorizontalDragCancel: _onBottomBarDragCancel,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.onSurfaceVariant,
                backgroundColor: (brightness == Brightness.dark
                        ? const Color(0xFF1C1C1E)
                        : Colors.white)
                    .withValues(alpha: 0.68),
                borderColor: brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.78),
              ),
            );
          },
        ),
      ),
    );
  }

  List<_NavItemData> _buildNavItems(BuildContext context) {
    return [
      _NavItemData(
        label: context.t(pt: 'Mistura', en: 'Mix'),
        icon: CupertinoIcons.drop,
        activeIcon: CupertinoIcons.drop_fill,
      ),
      _NavItemData(
        label: context.t(pt: 'Consumo', en: 'Usage'),
        icon: CupertinoIcons.speedometer,
        activeIcon: CupertinoIcons.speedometer,
      ),
      _NavItemData(
        label: context.t(pt: 'Histórico', en: 'History'),
        icon: CupertinoIcons.clock,
        activeIcon: CupertinoIcons.clock_fill,
      ),
      if (_isProUnlocked)
        const _NavItemData(
          label: 'Pro',
          icon: CupertinoIcons.star,
          activeIcon: CupertinoIcons.star_fill,
        ),
      _NavItemData(
        label: context.t(pt: 'Configurações', en: 'Settings'),
        icon: CupertinoIcons.settings,
        activeIcon: CupertinoIcons.settings_solid,
      ),
    ];
  }
}

class _FuelTuneBottomBar extends StatelessWidget {
  const _FuelTuneBottomBar({
    required this.items,
    required this.selectedIndex,
    required this.pageProgress,
    required this.onTap,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragEnd,
    required this.onHorizontalDragCancel,
    required this.activeColor,
    required this.inactiveColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  static const double _maxSlotExtent = 56;
  static const double _barPadding = 8;

  final List<_NavItemData> items;
  final int selectedIndex;
  final double pageProgress;
  final ValueChanged<int> onTap;
  final ValueChanged<double> onHorizontalDragUpdate;
  final ValueChanged<double> onHorizontalDragEnd;
  final VoidCallback onHorizontalDragCancel;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final useBackdropBlur = defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS;
          final preferredBarWidth =
              (items.length * _maxSlotExtent) + (_barPadding * 2);
          final availableWidth = constraints.maxWidth;
          final cappedBarWidth = preferredBarWidth.clamp(0.0, availableWidth);
          final slotExtent =
              ((cappedBarWidth - (_barPadding * 2)) / items.length)
                  .clamp(38.0, _maxSlotExtent)
                  .toDouble();
          final barWidth = (slotExtent * items.length) + (_barPadding * 2);
          final progress =
              pageProgress.clamp(0.0, (items.length - 1).toDouble()).toDouble();
          final viewportWidth = MediaQuery.sizeOf(context).width;
          final dragScale = ((viewportWidth / slotExtent) * 0.84).clamp(
            1.0,
            7.2,
          );

          final barContent = Container(
            width: barWidth,
            height: 60,
            padding: const EdgeInsets.all(_barPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: borderColor),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.alphaBlend(
                    Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
                    backgroundColor,
                  ),
                  backgroundColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                  blurRadius: useBackdropBlur ? 28 : 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: progress * slotExtent,
                  top: 1,
                  child: IgnorePointer(
                    child: _LiquidGlassIndicator(
                      width: slotExtent - 4,
                      height: 42,
                      accentColor: activeColor,
                      isDark: isDark,
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var index = 0; index < items.length; index++)
                      Expanded(
                        child: _BottomBarItem(
                          item: items[index],
                          isSelected: selectedIndex == index,
                          emphasis:
                              (1 - (progress - index).abs()).clamp(0.0, 1.0),
                          slotExtent: slotExtent,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => onTap(index),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );

          final wrappedBar = useBackdropBlur
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: barContent,
                  ),
                )
              : barContent;

          return RepaintBoundary(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                onHorizontalDragUpdate(details.delta.dx * dragScale);
              },
              onHorizontalDragEnd: (details) {
                onHorizontalDragEnd(details.velocity.pixelsPerSecond.dx);
              },
              onHorizontalDragCancel: onHorizontalDragCancel,
              child: wrappedBar,
            ),
          );
        },
      ),
    );
  }
}

class _LiquidGlassIndicator extends StatelessWidget {
  const _LiquidGlassIndicator({
    required this.width,
    required this.height,
    required this.accentColor,
    required this.isDark,
  });

  final double width;
  final double height;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.58),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              Colors.white.withValues(alpha: isDark ? 0.08 : 0.34),
              accentColor.withValues(alpha: isDark ? 0.16 : 0.14),
            ),
            Color.alphaBlend(
              accentColor.withValues(alpha: isDark ? 0.14 : 0.1),
              Colors.white.withValues(alpha: isDark ? 0.06 : 0.18),
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.1 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.item,
    required this.isSelected,
    required this.emphasis,
    required this.slotExtent,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final _NavItemData item;
  final bool isSelected;
  final double emphasis;
  final double slotExtent;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final emphasisCurve = Curves.easeOut.transform(emphasis);
    final effectiveColor = Color.lerp(
      inactiveColor.withValues(alpha: 0.92),
      activeColor,
      emphasisCurve,
    )!;
    final iconScale = lerpDouble(1, 1.08, emphasisCurve)!;

    return Semantics(
      label: item.label,
      button: true,
      selected: isSelected,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        pressedOpacity: 0.9,
        onPressed: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: Center(
            child: Transform.scale(
              scale: iconScale,
              child: Icon(
                emphasis >= 0.55 ? item.activeIcon : item.icon,
                size: emphasis >= 0.55 ? 21 : 20,
                color: effectiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

enum _HomeTab {
  mixture,
  consumption,
  history,
  premium,
  settings,
}
