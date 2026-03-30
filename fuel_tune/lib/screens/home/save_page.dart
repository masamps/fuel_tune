import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tune/config/fuel_tune_plan.dart';
import 'package:fuel_tune/l10n/app_language_scope.dart';
import 'package:fuel_tune/models/fuel_record.dart';
import 'package:fuel_tune/repositories/fuel_record_repository.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';
import 'package:fuel_tune/screens/premium/premium_insights_page.dart';
import 'package:fuel_tune/widgets/apple_page_layout.dart';
import 'package:fuel_tune/widgets/apple_section_card.dart';
import 'package:fuel_tune/widgets/fuel_tune_pro_sheet.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.appStateVersion});

  final ValueNotifier<int>? appStateVersion;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FuelRecordRepository _repository = FuelRecordRepository();
  final LocalPreferencesRepository _preferencesRepository =
      LocalPreferencesRepository();

  List<FuelRecord> registros = [];
  bool isLoading = true;
  bool _isProUnlocked = false;

  @override
  void initState() {
    super.initState();
    widget.appStateVersion?.addListener(_handleExternalAppStateChange);
    _carregarDados();
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.appStateVersion != widget.appStateVersion) {
      oldWidget.appStateVersion?.removeListener(_handleExternalAppStateChange);
      widget.appStateVersion?.addListener(_handleExternalAppStateChange);
    }
  }

  @override
  void dispose() {
    widget.appStateVersion?.removeListener(_handleExternalAppStateChange);
    super.dispose();
  }

  void _handleExternalAppStateChange() {
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final loadedRecords = await _repository.loadRecords();
    final isProUnlocked = await _preferencesRepository.loadIsProUnlocked();

    if (!mounted) {
      return;
    }

    setState(() {
      registros = loadedRecords;
      _isProUnlocked = isProUnlocked;
      isLoading = false;
    });
  }

  Future<void> _deletarRegistro(int index) async {
    final removedRecord = registros[index];

    setState(() {
      registros.removeAt(index);
    });

    await _repository.saveRecords(registros);

    if (widget.appStateVersion != null) {
      widget.appStateVersion!.value++;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.t(
            pt: 'Abastecimento removido do histórico.',
            en: 'Fuel log removed from history.',
          ),
        ),
        action: SnackBarAction(
          label: context.t(pt: 'Desfazer', en: 'Undo'),
          onPressed: () async {
            final restoredRecords = List<FuelRecord>.from(registros)
              ..insert(index, removedRecord);
            await _repository.saveRecords(restoredRecords);

            if (!mounted) {
              return;
            }

            setState(() {
              registros = restoredRecords;
            });

            if (widget.appStateVersion != null) {
              widget.appStateVersion!.value++;
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF9F0A);

    if (isLoading) {
      return ApplePageLayout(
        title: context.t(pt: 'Histórico', en: 'History'),
        subtitle: context.t(
          pt: 'Seus abastecimentos salvos aparecem aqui.',
          en: 'Your saved fuel logs appear here.',
        ),
        accentColor: accent,
        trailing: const _HistoryBadge(),
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 48),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    return ApplePageLayout(
      title: context.t(pt: 'Histórico', en: 'History'),
      subtitle: registros.isEmpty
          ? context.t(
              pt: 'Seus abastecimentos salvos aparecem aqui.',
              en: 'Your saved fuel logs appear here.',
            )
          : !_isProUnlocked &&
                  FuelTunePlan.hasReachedFreeHistoryLimit(registros.length)
              ? context.t(
                  pt: 'Voce atingiu o limite de ${FuelTunePlan.freeHistoryLimit} abastecimentos do plano gratis.',
                  en: 'You reached the free plan limit of ${FuelTunePlan.freeHistoryLimit} fuel logs.',
                )
              : context.t(
                  pt: '${registros.length} abastecimento${registros.length > 1 ? 's' : ''} salvo${registros.length > 1 ? 's' : ''}, do mais recente para o mais antigo.',
                  en: '${registros.length} fuel log${registros.length > 1 ? 's' : ''}, from newest to oldest.',
                ),
      accentColor: accent,
      trailing: const _HistoryBadge(),
      children: [
        AppleSectionCard(
          tintColor: const Color(0xFF0A84FF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isProUnlocked
                    ? context.t(
                        pt: 'Painel premium ativo',
                        en: 'Premium panel active',
                      )
                    : context.t(pt: 'Painel premium', en: 'Premium panel'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _isProUnlocked
                    ? context.t(
                        pt: 'Abra sua tela de medias, gastos e ultimos abastecimentos em uma leitura feita para consulta rapida.',
                        en: 'Open your dashboard with averages, spending, and recent fuel logs in a quick readout.',
                      )
                    : context.t(
                        pt: 'Veja a previa da tela premium com media em km/L, media de gasto, custo por km e mais contexto do seu historico.',
                        en: 'Preview the premium panel with km/L average, average spending, cost per km, and richer history context.',
                      ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _abrirPainelPremium,
                child: Text(
                  _isProUnlocked
                      ? context.t(
                          pt: 'Abrir painel premium',
                          en: 'Open premium panel',
                        )
                      : context.t(
                          pt: 'Ver painel premium',
                          en: 'View premium panel',
                        ),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF0A84FF),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (!_isProUnlocked && registros.isNotEmpty)
          AppleSectionCard(
            tintColor: const Color(0xFF0A84FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FuelTunePlan.hasReachedFreeHistoryLimit(registros.length)
                      ? context.t(
                          pt: 'Limite do plano gratis atingido',
                          en: 'Free plan limit reached',
                        )
                      : context.t(
                          pt: 'Plano gratis em uso',
                          en: 'Free plan in use',
                        ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  FuelTunePlan.hasReachedFreeHistoryLimit(registros.length)
                      ? context.t(
                          pt: 'Voce chegou a ${FuelTunePlan.freeHistoryLimit} abastecimentos salvos. O ${FuelTunePlan.proName} libera historico ilimitado e estatisticas do carro.',
                          en: 'You reached ${FuelTunePlan.freeHistoryLimit} saved fuel logs. ${FuelTunePlan.proName} unlocks unlimited history and car statistics.',
                        )
                      : context.t(
                          pt: 'Voce ja salvou ${registros.length} de ${FuelTunePlan.freeHistoryLimit} abastecimentos no plano gratis.',
                          en: 'You have already saved ${registros.length} of ${FuelTunePlan.freeHistoryLimit} fuel logs on the free plan.',
                        ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _abrirOfertaPro,
                  child: Text(
                    context.t(pt: 'Conhecer o Pro', en: 'Explore Pro'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF0A84FF),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
        if (registros.isEmpty)
          AppleSectionCard(
            tintColor: accent,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Icon(
                  CupertinoIcons.clock,
                  size: 34,
                  color: accent.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 14),
                Text(
                  context.t(
                    pt: 'Você ainda não salvou nenhum abastecimento.',
                    en: 'You have not saved any fuel log yet.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t(
                    pt: 'Assim que você registrar um abastecimento, ele aparece aqui com data, consumo e valor pago.',
                    en: 'As soon as you save a fuel log, it will appear here with date, consumption, and amount paid.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          )
        else
          ...registros.asMap().entries.map((entry) {
            final index = entry.key;
            final registro = entry.value;

            return Dismissible(
              key: Key('${registro.fueledAt.toIso8601String()}-$index'),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Icon(
                  CupertinoIcons.delete_solid,
                  color: Colors.white,
                ),
              ),
              onDismissed: (_) => _deletarRegistro(index),
              child: AppleSectionCard(
                tintColor: accent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.formatNumberText(registro.averageConsumption)} km/L',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.formatDateTimeText(registro.fueledAt),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _HistoryInfoChip(
                          label: context.t(pt: 'Distância', en: 'Distance'),
                          value:
                              '${context.formatCompactNumberText(registro.distanceKm)} km',
                          tintColor: accent,
                        ),
                        _HistoryInfoChip(
                          label: context.t(pt: 'Litros', en: 'Liters'),
                          value:
                              '${context.formatNumberText(registro.litersFilled)} L',
                          tintColor: accent,
                        ),
                        if (registro.amountPaid != null)
                          _HistoryInfoChip(
                            label:
                                context.t(pt: 'Valor pago', en: 'Amount paid'),
                            value: context.formatCurrencyText(
                              registro.amountPaid!,
                            ),
                            tintColor: accent,
                          ),
                      ],
                    ),
                    if (registro.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        registro.notes.trim(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _abrirOfertaPro() async {
    await showFuelTuneProSheet(
      context: context,
      isProUnlocked: _isProUnlocked,
      onProStatusChanged: _handleProStatusChanged,
    );
  }

  Future<void> _handleProStatusChanged() async {
    await _carregarDados();

    if (widget.appStateVersion != null) {
      widget.appStateVersion!.value++;
    }
  }

  Future<void> _abrirPainelPremium() async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => PremiumInsightsPage(
          appStateVersion: widget.appStateVersion,
        ),
      ),
    );
  }
}

class _HistoryInfoChip extends StatelessWidget {
  const _HistoryInfoChip({
    required this.label,
    required this.value,
    required this.tintColor,
  });

  final String label;
  final String value;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tintColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryBadge extends StatelessWidget {
  const _HistoryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFF9F0A).withValues(alpha: 0.15),
        border: Border.all(
          color: const Color(0xFFFF9F0A).withValues(alpha: 0.18),
        ),
      ),
      child: const Icon(CupertinoIcons.clock_fill, color: Color(0xFFFF9F0A)),
    );
  }
}
