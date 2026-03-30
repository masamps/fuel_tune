import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tune/config/fuel_tune_plan.dart';
import 'package:fuel_tune/l10n/app_language_scope.dart';
import 'package:fuel_tune/models/fuel_record.dart';
import 'package:fuel_tune/models/fuel_statistics_summary.dart';
import 'package:fuel_tune/repositories/fuel_record_repository.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';
import 'package:fuel_tune/services/fuel_statistics_service.dart';
import 'package:fuel_tune/services/pro_access_service.dart';
import 'package:fuel_tune/widgets/apple_button.dart';
import 'package:fuel_tune/widgets/apple_page_layout.dart';
import 'package:fuel_tune/widgets/apple_section_card.dart';
import 'package:fuel_tune/widgets/fuel_tune_pro_sheet.dart';

class PremiumInsightsPage extends StatefulWidget {
  PremiumInsightsPage({
    super.key,
    this.appStateVersion,
    FuelRecordRepository? repository,
    LocalPreferencesRepository? preferencesRepository,
  })  : repository = repository ?? FuelRecordRepository(),
        preferencesRepository =
            preferencesRepository ?? LocalPreferencesRepository();

  final ValueNotifier<int>? appStateVersion;
  final FuelRecordRepository repository;
  final LocalPreferencesRepository preferencesRepository;

  @override
  State<PremiumInsightsPage> createState() => _PremiumInsightsPageState();
}

class _PremiumInsightsPageState extends State<PremiumInsightsPage> {
  final ProAccessService _proAccessService = ProAccessService();
  bool _isLoading = true;
  bool _isProUnlocked = false;
  FuelStatisticsSummary _summary = const FuelStatisticsSummary.empty();

  @override
  void initState() {
    super.initState();
    widget.appStateVersion?.addListener(_handleExternalStateChange);
    _loadData();
  }

  @override
  void didUpdateWidget(covariant PremiumInsightsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.appStateVersion != widget.appStateVersion) {
      oldWidget.appStateVersion?.removeListener(_handleExternalStateChange);
      widget.appStateVersion?.addListener(_handleExternalStateChange);
    }
  }

  @override
  void dispose() {
    widget.appStateVersion?.removeListener(_handleExternalStateChange);
    super.dispose();
  }

  void _handleExternalStateChange() {
    _loadData();
  }

  Future<void> _loadData() async {
    final isProUnlocked =
        await widget.preferencesRepository.loadIsProUnlocked();
    final records = await widget.repository.loadRecords();
    final summary = FuelStatisticsService.summarize(records);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _isProUnlocked = isProUnlocked;
      _summary = summary;
    });
  }

  Future<void> _openProOffer() async {
    await showFuelTuneProSheet(
      context: context,
      isProUnlocked: _isProUnlocked,
      onProStatusChanged: _handleProStatusChanged,
    );
  }

  Future<void> _handleProStatusChanged() async {
    if (widget.appStateVersion != null) {
      widget.appStateVersion!.value++;
    }

    await _loadData();
  }

  Future<void> _activateProInDebugMode() async {
    final successMessage = context.t(
      pt: 'Fuel Tune Pro ativado em modo debug.',
      en: 'Fuel Tune Pro enabled in debug mode.',
    );

    await _proAccessService.unlockPro();
    await _handleProStatusChanged();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0A84FF);

    return Scaffold(
      body: ApplePageLayout(
        title: _isProUnlocked
            ? context.t(pt: 'Painel premium', en: 'Premium panel')
            : context.t(pt: 'Painel do Pro', en: 'Pro panel'),
        subtitle: _isProUnlocked
            ? context.t(
                pt: 'Consumo, gasto e historico em uma leitura clara do uso do carro.',
                en: 'Consumption, spending, and history in a clear snapshot of how you use the car.',
              )
            : context.t(
                pt: 'Uma tela feita para transformar seus abastecimentos em uma leitura bonita e util no dia a dia.',
                en: 'A screen designed to turn your fuel logs into a beautiful and useful daily readout.',
              ),
        accentColor: accent,
        trailing: const _PremiumBadge(),
        children: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 48),
                child: CircularProgressIndicator(),
              ),
            )
          else if (!_isProUnlocked) ...[
            _PremiumHeroCard(
              isLocked: true,
              summary: _summary.hasRecords ? _summary : _sampleSummary,
            ),
            _LockedPreviewCard(
              summary: _summary.hasRecords ? _summary : _sampleSummary,
            ),
            AppleSectionCard(
              tintColor: accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t(
                      pt: 'O que voce libera no ${FuelTunePlan.proName}',
                      en: 'What you unlock with ${FuelTunePlan.proName}',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.t(
                      pt: 'Historico ilimitado, medias de consumo, media de gasto, custo por km e um painel pronto para consulta rapida.',
                      en: 'Unlimited history, consumption averages, average spending, cost per km, and a dashboard ready for quick checks.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 18),
                  AppleButton(
                    label: context.t(
                      pt: 'Desbloquear Fuel Tune Pro',
                      en: 'Unlock Fuel Tune Pro',
                    ),
                    onPressed: _openProOffer,
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 12),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _activateProInDebugMode,
                      child: Text(
                        context.t(
                          pt: 'Ativar Pro no modo debug',
                          en: 'Enable Pro in debug mode',
                        ),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else if (!_summary.hasRecords) ...[
            _PremiumHeroCard(
              isLocked: false,
              summary: _sampleSummary,
            ),
            AppleSectionCard(
              tintColor: accent,
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    size: 34,
                    color: accent.withValues(alpha: 0.92),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.t(
                      pt: 'Seu painel premium ja esta pronto.',
                      en: 'Your premium panel is ready.',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.t(
                      pt: 'Assim que voce salvar abastecimentos no historico, esta tela passa a mostrar medias reais de consumo, gasto e custo por km.',
                      en: 'As soon as you save fuel logs to history, this screen starts showing real averages for consumption, spending, and cost per km.',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _PremiumHeroCard(
              isLocked: false,
              summary: _summary,
            ),
            AppleSectionCard(
              tintColor: accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t(pt: 'Resumo do carro', en: 'Car summary'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      _InsightStatCard(
                        label: context.t(pt: 'Media geral', en: 'Avg overall'),
                        value:
                            '${context.formatNumberText(_summary.averageConsumptionKmPerLiter)} km/L',
                        accentColor: accent,
                        icon: CupertinoIcons.speedometer,
                      ),
                      _InsightStatCard(
                        label: context.t(pt: 'Melhor media', en: 'Best avg'),
                        value:
                            '${context.formatNumberText(_summary.bestConsumptionKmPerLiter)} km/L',
                        accentColor: const Color(0xFF30D158),
                        icon: CupertinoIcons.arrow_up_right_circle_fill,
                      ),
                      _InsightStatCard(
                        label: context.t(pt: 'Menor media', en: 'Lowest avg'),
                        value:
                            '${context.formatNumberText(_summary.worstConsumptionKmPerLiter)} km/L',
                        accentColor: const Color(0xFFFF9F0A),
                        icon: CupertinoIcons.arrow_down_right_circle_fill,
                      ),
                      _InsightStatCard(
                        label: context.t(pt: 'Total rodado', en: 'Distance'),
                        value:
                            '${context.formatCompactNumberText(_summary.totalDistanceKm)} km',
                        accentColor: const Color(0xFFBF5AF2),
                        icon: CupertinoIcons.location_fill,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppleSectionCard(
              tintColor: const Color(0xFF30D158),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t(pt: 'Gastos', en: 'Spending'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _summary.hasAmountInsights
                        ? context.t(
                            pt: 'Baseado em ${_summary.paidRecordsCount} abastecimento${_summary.paidRecordsCount > 1 ? 's' : ''} com valor pago.',
                            en: 'Based on ${_summary.paidRecordsCount} fuel log${_summary.paidRecordsCount > 1 ? 's' : ''} with amount paid.',
                          )
                        : context.t(
                            pt: 'Preencha o valor pago para liberar as metricas de gasto.',
                            en: 'Fill in the amount paid to unlock spending metrics.',
                          ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      _InsightStatCard(
                        label: context.t(pt: 'Media de gasto', en: 'Avg spend'),
                        value: _summary.averageAmountPaid != null
                            ? context.formatCurrencyText(
                                _summary.averageAmountPaid!,
                              )
                            : '--',
                        accentColor: const Color(0xFF30D158),
                        icon: CupertinoIcons.money_dollar_circle_fill,
                      ),
                      _InsightStatCard(
                        label: context.t(pt: 'Total gasto', en: 'Total spent'),
                        value: _summary.totalAmountPaid != null
                            ? context
                                .formatCurrencyText(_summary.totalAmountPaid!)
                            : '--',
                        accentColor: const Color(0xFFFF9F0A),
                        icon: CupertinoIcons.creditcard_fill,
                      ),
                      _InsightStatCard(
                        label: context.t(pt: 'Custo por km', en: 'Cost per km'),
                        value: _summary.costPerKm != null
                            ? '${context.formatCurrencyText(_summary.costPerKm!)}/km'
                            : '--',
                        accentColor: const Color(0xFF64D2FF),
                        icon: CupertinoIcons.chart_bar_circle_fill,
                      ),
                      _InsightStatCard(
                        label: context.t(
                            pt: 'Litros abastecidos', en: 'Liters filled'),
                        value:
                            '${context.formatNumberText(_summary.totalLitersFilled)} L',
                        accentColor: const Color(0xFFBF5AF2),
                        icon: CupertinoIcons.drop_fill,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppleSectionCard(
              tintColor: accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t(
                        pt: 'Ultimos abastecimentos', en: 'Recent fuel logs'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ..._summary.recentRecords.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RecentRecordTile(record: record),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

FuelStatisticsSummary get _sampleSummary => FuelStatisticsSummary(
      totalRecords: 12,
      totalDistanceKm: 3120,
      totalLitersFilled: 251.4,
      averageConsumptionKmPerLiter: 12.4,
      bestConsumptionKmPerLiter: 13.8,
      worstConsumptionKmPerLiter: 10.9,
      averageAmountPaid: 162.8,
      totalAmountPaid: 1953.6,
      costPerKm: 0.63,
      paidRecordsCount: 12,
      lastFueledAt: DateTime(2026, 3, 18, 18, 42),
      recentRecords: [
        FuelRecord(
          distanceKm: 328,
          litersFilled: 27.1,
          averageConsumption: 12.1,
          fueledAt: DateTime(2026, 3, 18, 18, 42),
          amountPaid: 151.2,
        ),
        FuelRecord(
          distanceKm: 340,
          litersFilled: 26.5,
          averageConsumption: 12.8,
          fueledAt: DateTime(2026, 3, 10, 9, 20),
          amountPaid: 158.9,
        ),
        FuelRecord(
          distanceKm: 296,
          litersFilled: 24.7,
          averageConsumption: 12.0,
          fueledAt: DateTime(2026, 3, 1, 13, 5),
          amountPaid: 144.5,
        ),
      ],
    );

class _PremiumHeroCard extends StatelessWidget {
  const _PremiumHeroCard({
    required this.isLocked,
    required this.summary,
  });

  final bool isLocked;
  final FuelStatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A84FF),
            Color.alphaBlend(
              const Color(0xFF64D2FF).withValues(alpha: 0.45),
              const Color(0xFF0A84FF),
            ),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220A84FF),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              isLocked
                  ? context.t(pt: 'Preview premium', en: 'Premium preview')
                  : FuelTunePlan.proName,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isLocked
                ? context.t(
                    pt: 'Uma leitura que faz o historico virar decisao.',
                    en: 'A readout that turns history into decisions.',
                  )
                : context.t(
                    pt: 'Seu carro em numeros que batem o olho.',
                    en: 'Your car in numbers you can read at a glance.',
                  ),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isLocked
                ? context.t(
                    pt: 'Consumo, gasto medio, custo por km e um resumo bonito dos seus abastecimentos.',
                    en: 'Consumption, average spending, cost per km, and a beautiful summary of your fuel logs.',
                  )
                : context.t(
                    pt: 'Com abastecimentos salvos, o Painel premium mostra medias, gastos e os ultimos registros com leitura rapida.',
                    en: 'With saved fuel logs, the premium panel shows averages, spending, and recent records in a quick readout.',
                  ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 380;
              final averageMetric = _HeroMetric(
                label: context.t(pt: 'Media', en: 'Average'),
                value:
                    '${context.formatTrimmedNumberText(summary.averageConsumptionKmPerLiter)} km/L',
              );
              final averageSpendMetric = _HeroMetric(
                label: context.t(pt: 'Gasto medio', en: 'Avg spend'),
                value: summary.averageAmountPaid != null
                    ? context.formatCurrencyText(summary.averageAmountPaid!)
                    : '--',
              );
              final recordsMetric = _HeroMetric(
                label: context.t(pt: 'Registros', en: 'Records'),
                value: '${summary.totalRecords}',
              );

              if (!isCompact) {
                return Row(
                  children: [
                    Expanded(child: averageMetric),
                    const SizedBox(width: 10),
                    Expanded(child: averageSpendMetric),
                    const SizedBox(width: 10),
                    Expanded(child: recordsMetric),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: averageMetric),
                      const SizedBox(width: 10),
                      Expanded(child: averageSpendMetric),
                    ],
                  ),
                  const SizedBox(height: 10),
                  recordsMetric,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedPreviewCard extends StatelessWidget {
  const _LockedPreviewCard({
    required this.summary,
  });

  final FuelStatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.35,
          child: AppleSectionCard(
            tintColor: const Color(0xFF0A84FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t(
                    pt: 'O que aparece no painel',
                    en: 'What appears in the panel',
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _InsightStatCard(
                      label: context.t(pt: 'Media geral', en: 'Avg overall'),
                      value:
                          '${context.formatNumberText(summary.averageConsumptionKmPerLiter)} km/L',
                      accentColor: const Color(0xFF0A84FF),
                      icon: CupertinoIcons.speedometer,
                    ),
                    _InsightStatCard(
                      label: context.t(pt: 'Media de gasto', en: 'Avg spend'),
                      value: summary.averageAmountPaid != null
                          ? context
                              .formatCurrencyText(summary.averageAmountPaid!)
                          : '--',
                      accentColor: const Color(0xFF30D158),
                      icon: CupertinoIcons.money_dollar_circle_fill,
                    ),
                    _InsightStatCard(
                      label: context.t(pt: 'Custo por km', en: 'Cost per km'),
                      value: summary.costPerKm != null
                          ? '${context.formatCurrencyText(summary.costPerKm!)}/km'
                          : '--',
                      accentColor: const Color(0xFFFF9F0A),
                      icon: CupertinoIcons.chart_bar_circle_fill,
                    ),
                    _InsightStatCard(
                      label: context.t(pt: 'Total rodado', en: 'Distance'),
                      value:
                          '${context.formatCompactNumberText(summary.totalDistanceKm)} km',
                      accentColor: const Color(0xFFBF5AF2),
                      icon: CupertinoIcons.location_fill,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.black.withValues(alpha: 0.06),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(
                        alpha: 0.92,
                      ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.lock_fill,
                      color: Color(0xFF0A84FF),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.t(
                        pt: 'Painel exclusivo do Pro',
                        en: 'Exclusive Pro panel',
                      ),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightStatCard extends StatelessWidget {
  const _InsightStatCard({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRecordTile extends StatelessWidget {
  const _RecentRecordTile({
    required this.record,
  });

  final FuelRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              CupertinoIcons.drop_fill,
              color: Color(0xFF0A84FF),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.formatTrimmedNumberText(record.averageConsumption)} km/L',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.formatDateTimeText(record.fueledAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${context.formatTrimmedNumberText(record.litersFilled)} L',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                record.amountPaid != null
                    ? context.formatCurrencyText(record.amountPaid!)
                    : '--',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
        border: Border.all(
          color: const Color(0xFF0A84FF).withValues(alpha: 0.18),
        ),
      ),
      child: const Icon(
        CupertinoIcons.star_fill,
        color: Color(0xFF0A84FF),
      ),
    );
  }
}
