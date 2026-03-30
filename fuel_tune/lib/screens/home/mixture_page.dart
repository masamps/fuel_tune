import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tune/l10n/app_language_scope.dart';
import 'package:fuel_tune/models/fuel_blend.dart';
import 'package:fuel_tune/services/calculo_combustivel.dart';
import 'package:fuel_tune/utils/number_utils.dart';
import 'package:fuel_tune/widgets/apple_button.dart';
import 'package:fuel_tune/widgets/apple_choice_chip.dart';
import 'package:fuel_tune/widgets/apple_page_layout.dart';
import 'package:fuel_tune/widgets/apple_section_card.dart';
import 'package:fuel_tune/widgets/input_field_widget.dart';

class MixturePage extends StatefulWidget {
  const MixturePage({super.key});

  @override
  State<MixturePage> createState() => _MixturePageState();
}

class _MixturePageState extends State<MixturePage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController ethanolPriceController = TextEditingController();
  final TextEditingController gasolinePriceController = TextEditingController();
  final TextEditingController customPercentageController =
      TextEditingController();

  bool isByLiters = true;
  String selectedBlendId = 'e75';
  FuelMixResult? result;

  @override
  void dispose() {
    amountController.dispose();
    ethanolPriceController.dispose();
    gasolinePriceController.dispose();
    customPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedBlend = fuelBlendById(selectedBlendId);
    const ethanolTint = Color(0xFFFF6B6B);
    const gasolineTint = Color(0xFF0A84FF);

    return ApplePageLayout(
      title: context.t(pt: 'Mistura', en: 'Mix'),
      subtitle: context.t(
        pt: 'Monte a proporção ideal com uma leitura rápida, limpa e próxima do que você usaria todos os dias no carro.',
        en: 'Build the ideal blend with a quick, clean readout that feels natural for daily use.',
      ),
      accentColor: gasolineTint,
      trailing: const _HeaderBadge(
        icon: CupertinoIcons.drop_fill,
        tintColor: gasolineTint,
      ),
      children: [
        AppleSectionCard(
          tintColor: gasolineTint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t(
                  pt: 'Como você quer calcular?',
                  en: 'How do you want to calculate?',
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              CupertinoSlidingSegmentedControl<bool>(
                groupValue: isByLiters,
                children: {
                  true: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Text(context.t(pt: 'Por litros', en: 'By liters')),
                  ),
                  false: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Text(context.t(pt: 'Por valor', en: 'By amount')),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    isByLiters = value;
                    result = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                context.t(pt: 'Mistura desejada', en: 'Target blend'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final option in fuelBlendOptions)
                    AppleChoiceChip(
                      label: option.isCustom
                          ? context.t(pt: 'Personalizada', en: 'Custom')
                          : option.label,
                      selected: selectedBlendId == option.id,
                      tintColor: gasolineTint,
                      onPressed: () {
                        setState(() {
                          selectedBlendId = option.id;
                          result = null;
                        });
                      },
                    ),
                ],
              ),
              if (selectedBlend.isCustom) ...[
                const SizedBox(height: 18),
                InputFieldWidget(
                  controller: customPercentageController,
                  labelText: context.t(
                    pt: 'Percentual de etanol',
                    en: 'Ethanol percentage',
                  ),
                  hintText: context.t(pt: 'Ex: 62,5', en: 'Eg: 62.5'),
                  suffixText: '%',
                ),
              ],
              const SizedBox(height: 18),
              InputFieldWidget(
                controller: amountController,
                labelText: isByLiters
                    ? context.t(
                        pt: 'Quanto você vai abastecer?',
                        en: 'How much will you fill?',
                      )
                    : context.t(
                        pt: 'Valor total do abastecimento',
                        en: 'Total fueling amount',
                      ),
                hintText: isByLiters
                    ? context.t(pt: 'Ex: 20', en: 'Eg: 20')
                    : context.t(pt: 'Ex: 120,00', en: 'Eg: 120.00'),
                suffixText: isByLiters ? 'L' : null,
                prefixText: isByLiters ? null : 'R\$ ',
              ),
              if (!isByLiters) ...[
                const SizedBox(height: 18),
                InputFieldWidget(
                  controller: ethanolPriceController,
                  labelText:
                      context.t(pt: 'Preço do etanol', en: 'Ethanol price'),
                  hintText: context.t(pt: 'Ex: 4,29', en: 'Eg: 4.29'),
                  prefixText: 'R\$ ',
                ),
                const SizedBox(height: 18),
                InputFieldWidget(
                  controller: gasolinePriceController,
                  labelText:
                      context.t(pt: 'Preço da gasolina', en: 'Gasoline price'),
                  hintText: context.t(pt: 'Ex: 5,79', en: 'Eg: 5.79'),
                  prefixText: 'R\$ ',
                ),
              ],
              const SizedBox(height: 22),
              AppleButton(
                label: context.t(
                  pt: 'Calcular resultado',
                  en: 'Calculate result',
                ),
                onPressed: _calculate,
              ),
            ],
          ),
        ),
        if (result != null)
          AppleSectionCard(
            tintColor: gasolineTint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.check_mark_circled_solid,
                      color: gasolineTint,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.t(pt: 'Resultado', en: 'Result'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.t(
                    pt: 'Para chegar em ${fuelBlendLabel(presetLabel: _localizedBlendLabel(context, selectedBlend), isCustom: selectedBlend.isCustom, customPercentage: parseFlexibleDouble(customPercentageController.text))}, abasteça:',
                    en: 'To reach ${fuelBlendLabel(presetLabel: _localizedBlendLabel(context, selectedBlend), isCustom: selectedBlend.isCustom, customPercentage: parseFlexibleDouble(customPercentageController.text))}, fill with:',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _ResultMetricTile(
                        label: context.t(pt: 'Etanol', en: 'Ethanol'),
                        value:
                            '${context.formatNumberText(result!.ethanolLiters)} L',
                        tintColor: ethanolTint,
                        icon: CupertinoIcons.drop_fill,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResultMetricTile(
                        label: context.t(pt: 'Gasolina', en: 'Gasoline'),
                        value:
                            '${context.formatNumberText(result!.gasolineLiters)} L',
                        tintColor: gasolineTint,
                        icon: CupertinoIcons.speedometer,
                      ),
                    ),
                  ],
                ),
                if (result!.totalLiters != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    context.t(
                      pt: 'Volume estimado: ${context.formatNumberText(result!.totalLiters!)} L',
                      en: 'Estimated volume: ${context.formatNumberText(result!.totalLiters!)} L',
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  void _calculate() {
    final selectedBlend = fuelBlendById(selectedBlendId);
    final customPercentage = parseFlexibleDouble(
      customPercentageController.text,
    );

    try {
      if (selectedBlend.isCustom &&
          (customPercentage == null ||
              customPercentage < 0 ||
              customPercentage > 100)) {
        throw ArgumentError(
          context.t(
            pt: 'Informe um percentual de etanol entre 0 e 100.',
            en: 'Enter an ethanol percentage between 0 and 100.',
          ),
        );
      }

      final amount = parseFlexibleDouble(amountController.text) ?? 0;

      if (amount <= 0) {
        throw ArgumentError(
          isByLiters
              ? context.t(
                  pt: 'Informe quantos litros você vai abastecer.',
                  en: 'Enter how many liters you want to fill.',
                )
              : context.t(
                  pt: 'Informe o valor total do abastecimento.',
                  en: 'Enter the total fueling amount.',
                ),
        );
      }

      if (!isByLiters) {
        final ethanolPrice =
            parseFlexibleDouble(ethanolPriceController.text) ?? 0;
        final gasolinePrice =
            parseFlexibleDouble(gasolinePriceController.text) ?? 0;

        if (ethanolPrice <= 0 || gasolinePrice <= 0) {
          throw ArgumentError(
            context.t(
              pt: 'Informe os preços do etanol e da gasolina.',
              en: 'Enter both ethanol and gasoline prices.',
            ),
          );
        }
      }

      final ethanolFraction = selectedBlend.resolveEthanolFraction(
        customPercentage,
      );

      final calculationResult = isByLiters
          ? FuelMixCalculator.calculateByLiters(
              totalLiters: amount,
              ethanolFraction: ethanolFraction,
            )
          : FuelMixCalculator.calculateByValue(
              totalAmount: amount,
              ethanolPrice:
                  parseFlexibleDouble(ethanolPriceController.text) ?? 0,
              gasolinePrice:
                  parseFlexibleDouble(gasolinePriceController.text) ?? 0,
              ethanolFraction: ethanolFraction,
            );

      setState(() {
        result = calculationResult;
      });
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
  }

  String _localizedBlendLabel(BuildContext context, FuelBlendOption option) {
    if (option.isCustom) {
      return context.t(pt: 'Personalizada', en: 'Custom');
    }

    return option.label;
  }
}

class _ResultMetricTile extends StatelessWidget {
  const _ResultMetricTile({
    required this.label,
    required this.value,
    required this.tintColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color tintColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tintColor.withValues(
              alpha: brightness == Brightness.dark ? 0.26 : 0.16,
            ),
            tintColor.withValues(
              alpha: brightness == Brightness.dark ? 0.14 : 0.08,
            ),
          ],
        ),
        border: Border.all(
          color: tintColor.withValues(
            alpha: brightness == Brightness.dark ? 0.28 : 0.18,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tintColor, size: 18),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.icon, required this.tintColor});

  final IconData icon;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tintColor.withValues(alpha: 0.14),
        border: Border.all(color: tintColor.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: tintColor),
    );
  }
}
