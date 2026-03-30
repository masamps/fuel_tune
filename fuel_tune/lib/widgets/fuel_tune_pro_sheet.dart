import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tune/config/fuel_tune_plan.dart';
import 'package:fuel_tune/l10n/app_language_scope.dart';
import 'package:fuel_tune/services/pro_access_service.dart';
import 'package:fuel_tune/widgets/apple_button.dart';
import 'package:fuel_tune/widgets/apple_section_card.dart';
import 'package:fuel_tune/widgets/input_field_widget.dart';

Future<void> showFuelTuneProSheet({
  required BuildContext context,
  required bool isProUnlocked,
  Future<void> Function()? onProStatusChanged,
}) {
  final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);

  return showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) {
      return _FuelTuneProSheet(
        isProUnlocked: isProUnlocked,
        scaffoldMessenger: scaffoldMessenger,
        onProStatusChanged: onProStatusChanged,
      );
    },
  );
}

class _FuelTuneProSheet extends StatefulWidget {
  const _FuelTuneProSheet({
    required this.isProUnlocked,
    this.scaffoldMessenger,
    this.onProStatusChanged,
  });

  final bool isProUnlocked;
  final ScaffoldMessengerState? scaffoldMessenger;
  final Future<void> Function()? onProStatusChanged;

  @override
  State<_FuelTuneProSheet> createState() => _FuelTuneProSheetState();
}

class _FuelTuneProSheetState extends State<_FuelTuneProSheet>
    with SingleTickerProviderStateMixin {
  static const _dismissDistance = 120.0;
  static const _dismissVelocity = 950.0;

  final ProAccessService _proAccessService = ProAccessService();
  final TextEditingController _couponController = TextEditingController();
  final FocusNode _couponFocusNode = FocusNode();
  late final AnimationController _offsetController =
      AnimationController.unbounded(vsync: this, value: 0)
        ..addListener(_handleOffsetChanged);

  bool _isApplyingCoupon = false;
  String? _couponMessage;
  bool _couponMessageIsError = false;
  String? _appliedCouponCode;
  int _appliedDiscountPercent = 0;
  double _appliedDiscountedPrice = FuelTunePlan.proPrice;

  double get _dragOffset => _offsetController.value;

  @override
  void dispose() {
    _offsetController
      ..removeListener(_handleOffsetChanged)
      ..dispose();
    _couponController.dispose();
    _couponFocusNode.dispose();
    super.dispose();
  }

  void _handleOffsetChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final nextOffset =
        (_dragOffset + (details.delta.dy * 0.92)).clamp(0.0, double.infinity);

    _offsetController.value = nextOffset;
  }

  Future<void> _handleVerticalDragEnd(DragEndDetails details) async {
    final velocityY = details.velocity.pixelsPerSecond.dy;

    if (velocityY > _dismissVelocity || _dragOffset > _dismissDistance) {
      await _dismissWithAnimation();
      return;
    }

    await _offsetController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _dismissWithAnimation() async {
    await _offsetController.animateTo(
      (_dismissDistance * 1.8).clamp(_dragOffset, double.infinity),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  void _setCouponMessage(String message, {required bool isError}) {
    if (!mounted) {
      return;
    }

    setState(() {
      _couponMessage = message;
      _couponMessageIsError = isError;
    });
  }

  void _handleCouponChanged(String value) {
    final normalizedCode = ProAccessService.normalizeCoupon(value);
    final shouldClearAppliedCoupon =
        _appliedCouponCode != null && normalizedCode != _appliedCouponCode;

    if (_couponMessage == null && !shouldClearAppliedCoupon) {
      return;
    }

    setState(() {
      _couponMessage = null;

      if (shouldClearAppliedCoupon) {
        _appliedCouponCode = null;
        _appliedDiscountPercent = 0;
        _appliedDiscountedPrice = FuelTunePlan.proPrice;
      }
    });
  }

  Future<void> _notifyProUnlocked(String snackbarMessage) async {
    final messenger = widget.scaffoldMessenger;

    await widget.onProStatusChanged?.call();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();

    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(snackbarMessage)),
    );
  }

  Future<void> _applyCoupon() async {
    if (_isApplyingCoupon) {
      return;
    }

    final rawCoupon = _couponController.text;
    final normalizedCode = ProAccessService.normalizeCoupon(rawCoupon);

    if (normalizedCode.isEmpty) {
      _setCouponMessage(
        context.t(
          pt: 'Digite um cupom para tentar liberar o Pro.',
          en: 'Enter a coupon code to try unlocking Pro.',
        ),
        isError: true,
      );
      return;
    }

    _couponFocusNode.unfocus();

    setState(() {
      _isApplyingCoupon = true;
      _couponMessage = null;
    });

    final result = await _proAccessService.redeemCoupon(normalizedCode);

    if (!mounted) {
      return;
    }

    switch (result.status) {
      case ProCouponRedemptionStatus.invalid:
        setState(() {
          _isApplyingCoupon = false;
          _appliedCouponCode = null;
          _appliedDiscountPercent = 0;
          _appliedDiscountedPrice = FuelTunePlan.proPrice;
        });
        _setCouponMessage(
          context.t(
            pt: 'Este cupom nao foi reconhecido. Confira o codigo e tente novamente.',
            en: 'This coupon was not recognized. Check the code and try again.',
          ),
          isError: true,
        );
        return;
      case ProCouponRedemptionStatus.discountApplied:
        final discountedPriceLabel =
            context.formatCurrencyText(result.discountedPrice);

        setState(() {
          _isApplyingCoupon = false;
          _appliedCouponCode = result.normalizedCode;
          _appliedDiscountPercent = result.discountPercent;
          _appliedDiscountedPrice = result.discountedPrice;
          _couponMessage = context.t(
            pt: 'Cupom aplicado com ${result.discountPercent}% de desconto. Novo valor: $discountedPriceLabel.',
            en: 'Coupon applied with ${result.discountPercent}% off. New price: $discountedPriceLabel.',
          );
          _couponMessageIsError = false;
        });
        return;
      case ProCouponRedemptionStatus.alreadyUnlocked:
        setState(() {
          _isApplyingCoupon = false;
          _appliedCouponCode = result.normalizedCode;
          _appliedDiscountPercent = result.discountPercent;
          _appliedDiscountedPrice = result.discountedPrice;
        });
        await _notifyProUnlocked(
          context.t(
            pt: 'O Fuel Tune Pro ja esta ativo neste dispositivo.',
            en: 'Fuel Tune Pro is already active on this device.',
          ),
        );
        return;
      case ProCouponRedemptionStatus.success:
        setState(() {
          _isApplyingCoupon = false;
          _appliedCouponCode = result.normalizedCode;
          _appliedDiscountPercent = result.discountPercent;
          _appliedDiscountedPrice = result.discountedPrice;
        });
        await _notifyProUnlocked(
          context.t(
            pt: 'Cupom aplicado com ${result.discountPercent}% de desconto. O Fuel Tune Pro foi liberado neste dispositivo.',
            en: 'Coupon applied with ${result.discountPercent}% off. Fuel Tune Pro has been unlocked on this device.',
          ),
        );
        return;
    }
  }

  Future<void> _handleDebugUnlock() async {
    final successMessage = context.t(
      pt: 'Fuel Tune Pro ativado em modo debug.',
      en: 'Fuel Tune Pro enabled in debug mode.',
    );

    await _proAccessService.unlockPro();

    if (!mounted) {
      return;
    }

    await _notifyProUnlocked(successMessage);
  }

  Future<void> _showPurchasePlaceholder() async {
    final currentPriceLabel =
        context.formatCurrencyText(_currentDiscountedPrice);

    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(
            context.t(
              pt: 'Compra em preparação',
              en: 'Purchase setup in progress',
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _appliedDiscountPercent > 0
                  ? context.t(
                      pt: 'A compra unica do ${FuelTunePlan.proName} sera conectada a App Store e ao Google Play no proximo passo. O desconto de $_appliedDiscountPercent% ja foi reconhecido e o valor atual ficou em $currentPriceLabel.',
                      en: 'The one-time purchase for ${FuelTunePlan.proName} will be connected to the App Store and Google Play in the next step. Your $_appliedDiscountPercent% discount is already recognized and the current price is $currentPriceLabel.',
                    )
                  : context.t(
                      pt: 'A compra unica do ${FuelTunePlan.proName} sera conectada a App Store e ao Google Play no proximo passo. Enquanto isso, voce ja pode aplicar um cupom promocional valido.',
                      en: 'The one-time purchase for ${FuelTunePlan.proName} will be connected to the App Store and Google Play in the next step. Meanwhile, you can already apply a valid promo code.',
                    ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.t(pt: 'Entendi', en: 'Got it')),
            ),
          ],
        );
      },
    );
  }

  double get _currentDiscountedPrice => _appliedDiscountedPrice;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0A84FF);
    final theme = Theme.of(context);
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final overlayAlpha = lerpDouble(
      0.26,
      0.0,
      (_dragOffset / 220).clamp(0.0, 1.0),
    )!;
    final maximumTargetHeight =
        widget.isProUnlocked ? screenHeight * 0.58 : screenHeight * 0.84;
    final availableHeight =
        math.max(320.0, screenHeight - viewInsetsBottom - 28);
    final sheetHeight = math.min(maximumTargetHeight, availableHeight);

    return Material(
      color: Colors.black.withValues(alpha: overlayAlpha),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16 + viewInsetsBottom),
              child: SizedBox(
                height: sheetHeight,
                child: AppleSectionCard(
                  tintColor: accent,
                  child: Column(
                    children: [
                      _SheetDragHandle(
                        onVerticalDragUpdate: _handleVerticalDragUpdate,
                        onVerticalDragEnd: _handleVerticalDragEnd,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: Text(
                                  FuelTunePlan.proName,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.isProUnlocked
                                    ? context.t(
                                        pt: 'O Pro ja esta ativo neste dispositivo.',
                                        en: 'Pro is already active on this device.',
                                      )
                                    : context.t(
                                        pt: 'Desbloqueie mais controle no dia a dia.',
                                        en: 'Unlock more control for everyday use.',
                                      ),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.isProUnlocked
                                    ? context.t(
                                        pt: 'Seu app tem historico ilimitado pronto para receber as proximas melhorias premium.',
                                        en: 'Your app has unlimited history ready for the next premium improvements.',
                                      )
                                    : context.t(
                                        pt: 'O Fuel Tune Pro foi pensado para quem quer historico ilimitado, estatisticas de consumo e uma experiencia mais completa no acompanhamento do carro.',
                                        en: 'Fuel Tune Pro is built for people who want unlimited history, usage statistics, and a fuller car tracking experience.',
                                      ),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const _BenefitRow(
                                icon: CupertinoIcons.clock_fill,
                                titlePt: 'Historico ilimitado',
                                titleEn: 'Unlimited history',
                                subtitlePt:
                                    'Continue registrando abastecimentos sem limite.',
                                subtitleEn:
                                    'Keep saving fuel logs without limits.',
                              ),
                              const SizedBox(height: 12),
                              const _BenefitRow(
                                icon: CupertinoIcons.chart_bar_alt_fill,
                                titlePt: 'Estatisticas do carro',
                                titleEn: 'Car statistics',
                                subtitlePt:
                                    'Veja media de consumo, gasto e custo por km.',
                                subtitleEn:
                                    'See average consumption, spending, and cost per km.',
                              ),
                              const SizedBox(height: 12),
                              const _BenefitRow(
                                icon: CupertinoIcons.star_fill,
                                titlePt: 'Recursos extras',
                                titleEn: 'Extra features',
                                subtitlePt:
                                    'Receba as proximas funcoes premium sem mudar o fluxo principal.',
                                subtitleEn:
                                    'Get upcoming premium features without changing the main flow.',
                              ),
                              if (!widget.isProUnlocked) ...[
                                const SizedBox(height: 24),
                                _PurchaseCard(
                                  accent: accent,
                                  basePriceLabel: context.formatCurrencyText(
                                    FuelTunePlan.proPrice,
                                  ),
                                  discountedPriceLabel:
                                      context.formatCurrencyText(
                                    _currentDiscountedPrice,
                                  ),
                                  appliedDiscountPercent:
                                      _appliedDiscountPercent,
                                  isApplyingCoupon: _isApplyingCoupon,
                                  couponField: InputFieldWidget(
                                    controller: _couponController,
                                    focusNode: _couponFocusNode,
                                    labelText: context.t(
                                      pt: 'Cupom de desconto',
                                      en: 'Promo code',
                                    ),
                                    hintText: context.t(
                                      pt: 'Digite seu cupom de desconto',
                                      en: 'Enter your promo code',
                                    ),
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    onEditingComplete: _applyCoupon,
                                    onChanged: _handleCouponChanged,
                                  ),
                                  couponMessage: _couponMessage,
                                  couponMessageIsError: _couponMessageIsError,
                                  onBuyPressed: _showPurchasePlaceholder,
                                  onApplyCouponPressed: _applyCoupon,
                                ),
                              ],
                              const SizedBox(height: 18),
                              if (!widget.isProUnlocked && kDebugMode) ...[
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _handleDebugUnlock,
                                  child: Text(
                                    context.t(
                                      pt: 'Ativar Pro no modo debug',
                                      en: 'Enable Pro in debug mode',
                                    ),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  widget.isProUnlocked
                                      ? context.t(pt: 'Fechar', en: 'Close')
                                      : context.t(
                                          pt: 'Agora nao', en: 'Not now'),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle({
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
  });

  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({
    required this.accent,
    required this.basePriceLabel,
    required this.discountedPriceLabel,
    required this.appliedDiscountPercent,
    required this.isApplyingCoupon,
    required this.couponField,
    required this.onBuyPressed,
    required this.onApplyCouponPressed,
    this.couponMessage,
    required this.couponMessageIsError,
  });

  final Color accent;
  final String basePriceLabel;
  final String discountedPriceLabel;
  final int appliedDiscountPercent;
  final bool isApplyingCoupon;
  final Widget couponField;
  final String? couponMessage;
  final bool couponMessageIsError;
  final VoidCallback onBuyPressed;
  final VoidCallback onApplyCouponPressed;

  bool get _hasDiscount => appliedDiscountPercent > 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedbackColor = couponMessageIsError
        ? theme.colorScheme.error
        : const Color(0xFF30D158);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t(pt: 'Compra unica', en: 'One-time purchase'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.t(
                        pt: 'Desbloqueie o painel premium, historico ilimitado e futuras melhorias neste dispositivo.',
                        en: 'Unlock the premium dashboard, unlimited history, and future improvements on this device.',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_hasDiscount)
                    Text(
                      basePriceLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 2,
                      ),
                    ),
                  Text(
                    discountedPriceLabel,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  if (_hasDiscount) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF30D158).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '-$appliedDiscountPercent%',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF30D158),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppleButton(
            label: _hasDiscount
                ? context.t(
                    pt: 'Comprar com $appliedDiscountPercent% de desconto',
                    en: 'Buy with $appliedDiscountPercent% off',
                  )
                : context.t(
                    pt: 'Comprar Fuel Tune Pro',
                    en: 'Buy Fuel Tune Pro',
                  ),
            onPressed: onBuyPressed,
          ),
          const SizedBox(height: 16),
          couponField,
          const SizedBox(height: 12),
          _SecondarySheetButton(
            label: isApplyingCoupon
                ? context.t(pt: 'Aplicando cupom...', en: 'Applying code...')
                : context.t(pt: 'Aplicar cupom', en: 'Apply promo code'),
            onPressed: isApplyingCoupon ? null : onApplyCouponPressed,
          ),
          if (couponMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              couponMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: feedbackColor,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SecondarySheetButton extends StatelessWidget {
  const _SecondarySheetButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      pressedOpacity: 0.88,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colorScheme.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.14),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.titlePt,
    required this.titleEn,
    required this.subtitlePt,
    required this.subtitleEn,
  });

  final IconData icon;
  final String titlePt;
  final String titleEn;
  final String subtitlePt;
  final String subtitleEn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF0A84FF).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF0A84FF), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t(pt: titlePt, en: titleEn),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.t(pt: subtitlePt, en: subtitleEn),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
