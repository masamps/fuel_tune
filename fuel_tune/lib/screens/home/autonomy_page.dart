import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tune/config/fuel_tune_plan.dart';
import 'package:fuel_tune/l10n/app_language_scope.dart';
import 'package:fuel_tune/models/fuel_record.dart';
import 'package:fuel_tune/repositories/fuel_record_repository.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';
import 'package:fuel_tune/services/calculo_autonomia.dart';
import 'package:fuel_tune/utils/number_utils.dart';
import 'package:fuel_tune/widgets/apple_button.dart';
import 'package:fuel_tune/widgets/apple_page_layout.dart';
import 'package:fuel_tune/widgets/apple_section_card.dart';
import 'package:fuel_tune/widgets/fuel_tune_pro_sheet.dart';
import 'package:fuel_tune/widgets/input_field_widget.dart';

class ConsumptionPage extends StatefulWidget {
  ConsumptionPage({
    super.key,
    FuelRecordRepository? repository,
    LocalPreferencesRepository? preferencesRepository,
    this.appStateVersion,
  })  : repository = repository ?? FuelRecordRepository(),
        preferencesRepository =
            preferencesRepository ?? LocalPreferencesRepository();

  final FuelRecordRepository repository;
  final LocalPreferencesRepository preferencesRepository;
  final ValueNotifier<int>? appStateVersion;

  @override
  State<ConsumptionPage> createState() => _ConsumptionPageState();
}

class _ConsumptionPageState extends State<ConsumptionPage> {
  final TextEditingController kmController = TextEditingController();
  final TextEditingController litrosController = TextEditingController();
  final TextEditingController valorPagoController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  final ValueNotifier<double> _mediaConsumoNotifier = ValueNotifier(0);
  bool _isProUnlocked = false;
  int _savedRecordsCount = 0;
  bool _isLoadingPlanState = true;

  @override
  void initState() {
    super.initState();
    kmController.addListener(_calcularMedia);
    litrosController.addListener(_calcularMedia);
    widget.appStateVersion?.addListener(_handleExternalAppStateChange);
    _loadPlanState();
  }

  @override
  void didUpdateWidget(covariant ConsumptionPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.appStateVersion != widget.appStateVersion) {
      oldWidget.appStateVersion?.removeListener(_handleExternalAppStateChange);
      widget.appStateVersion?.addListener(_handleExternalAppStateChange);
    }
  }

  @override
  void dispose() {
    widget.appStateVersion?.removeListener(_handleExternalAppStateChange);
    kmController.dispose();
    litrosController.dispose();
    valorPagoController.dispose();
    observacaoController.dispose();
    _mediaConsumoNotifier.dispose();
    super.dispose();
  }

  void _handleExternalAppStateChange() {
    _loadPlanState();
  }

  Future<void> _loadPlanState() async {
    final isProUnlocked =
        await widget.preferencesRepository.loadIsProUnlocked();
    final records = await widget.repository.loadRecords();

    if (!mounted) {
      return;
    }

    setState(() {
      _isProUnlocked = isProUnlocked;
      _savedRecordsCount = records.length;
      _isLoadingPlanState = false;
    });
  }

  void _calcularMedia() {
    final kmPercorridos = parseFlexibleDouble(kmController.text) ?? 0.0;
    final litrosAbastecidos = parseFlexibleDouble(litrosController.text) ?? 0.0;
    final novaMedia = calculateAverageConsumption(
      kmPercorridos,
      litrosAbastecidos,
    );

    if (_mediaConsumoNotifier.value == novaMedia) {
      return;
    }

    _mediaConsumoNotifier.value = novaMedia;
  }

  Future<void> _salvarDados() async {
    final kmPercorrido = parseFlexibleDouble(kmController.text) ?? 0;
    final litrosAbastecidos = parseFlexibleDouble(litrosController.text) ?? 0;

    if (kmPercorrido <= 0 || litrosAbastecidos <= 0) {
      _exibirMensagemErro(
        context.t(
          pt: 'Preencha a distância e os litros abastecidos.',
          en: 'Fill in the distance and liters fueled.',
        ),
      );
      return;
    }

    try {
      final isProUnlocked =
          await widget.preferencesRepository.loadIsProUnlocked();
      final currentRecords = await widget.repository.loadRecords();

      if (!FuelTunePlan.canSaveRecord(
        isProUnlocked: isProUnlocked,
        currentRecordsCount: currentRecords.length,
      )) {
        if (mounted) {
          setState(() {
            _isProUnlocked = isProUnlocked;
            _savedRecordsCount = currentRecords.length;
            _isLoadingPlanState = false;
          });
        }

        await _mostrarAvisoLimiteAtingido();
        return;
      }

      final novoRegistro = FuelRecord(
        distanceKm: kmPercorrido,
        litersFilled: litrosAbastecidos,
        averageConsumption: _mediaConsumoNotifier.value,
        fueledAt: DateTime.now(),
        notes: observacaoController.text.trim(),
        amountPaid: parseFlexibleDouble(valorPagoController.text),
      );

      await widget.repository.saveRecord(novoRegistro);

      if (!mounted) {
        return;
      }

      setState(() {
        _isProUnlocked = isProUnlocked;
        _savedRecordsCount = currentRecords.length + 1;
        _isLoadingPlanState = false;
      });

      if (widget.appStateVersion != null) {
        widget.appStateVersion!.value++;
      }

      _exibirMensagemSucesso();
    } catch (_) {
      _exibirMensagemErro(
        context.t(
          pt: 'Não foi possível salvar o abastecimento agora.',
          en: 'Could not save the fuel log right now.',
        ),
      );
    }
  }

  Future<void> _mostrarAvisoLimiteAtingido() async {
    final action = await showCupertinoDialog<_LimitAction>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            context.t(
              pt: 'Limite do plano grátis atingido',
              en: 'Free plan limit reached',
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              context.t(
                pt: 'Voce ja salvou ${FuelTunePlan.freeHistoryLimit} abastecimentos. Para continuar registrando e liberar estatisticas do consumo, conheca o ${FuelTunePlan.proName}.',
                en: 'You have already saved ${FuelTunePlan.freeHistoryLimit} fuel logs. To keep saving records and unlock usage statistics, explore ${FuelTunePlan.proName}.',
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(_LimitAction.cancel),
              child: Text(context.t(pt: 'Agora nao', en: 'Not now')),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(_LimitAction.pro),
              child: Text(context.t(pt: 'Conhecer o Pro', en: 'Explore Pro')),
            ),
          ],
        );
      },
    );

    if (action == _LimitAction.pro && mounted) {
      await _abrirOfertaPro();
    }
  }

  Future<void> _abrirOfertaPro() async {
    await showFuelTuneProSheet(
      context: context,
      isProUnlocked: _isProUnlocked,
      onProStatusChanged: _handleProStatusChanged,
    );
  }

  Future<void> _handleProStatusChanged() async {
    await _loadPlanState();

    if (widget.appStateVersion != null) {
      widget.appStateVersion!.value++;
    }
  }

  void _exibirMensagemSucesso() {
    final snackBar = SnackBar(
      content: Text(
        context.t(
          pt: 'Abastecimento salvo no histórico.',
          en: 'Fuel log saved to history.',
        ),
      ),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _limparCampos();
  }

  void _exibirMensagemErro(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _limparCampos() {
    kmController.clear();
    litrosController.clear();
    valorPagoController.clear();
    observacaoController.clear();
    _mediaConsumoNotifier.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF30D158);

    return ApplePageLayout(
      title: context.t(pt: 'Consumo', en: 'Usage'),
      subtitle: context.t(
        pt: 'Registre o abastecimento sem fricção e acompanhe a média com uma leitura direta.',
        en: 'Save each fuel log without friction and track your average with a direct readout.',
      ),
      accentColor: accent,
      trailing: const _SummaryBadge(),
      children: [
        AppleSectionCard(
          tintColor: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t(pt: 'Registrar abastecimento', en: 'Save fuel log'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              InputFieldWidget(
                controller: kmController,
                labelText: context.t(
                  pt: 'Distância desde o último abastecimento',
                  en: 'Distance since the last fill-up',
                ),
                hintText: context.t(pt: 'Ex: 320', en: 'Eg: 320'),
                suffixText: 'km',
              ),
              const SizedBox(height: 18),
              InputFieldWidget(
                controller: litrosController,
                labelText: context.t(
                  pt: 'Litros abastecidos',
                  en: 'Liters fueled',
                ),
                hintText: context.t(pt: 'Ex: 28,5', en: 'Eg: 28.5'),
                suffixText: 'L',
              ),
              const SizedBox(height: 18),
              InputFieldWidget(
                controller: valorPagoController,
                labelText: context.t(pt: 'Valor pago', en: 'Amount paid'),
                hintText: context.t(pt: 'Ex: 149,90', en: 'Eg: 149.90'),
                prefixText: 'R\$ ',
              ),
              const SizedBox(height: 18),
              InputFieldWidget(
                controller: observacaoController,
                labelText: context.t(pt: 'Observação', en: 'Notes'),
                hintText: context.t(
                  pt: 'Ex: estrada e cidade',
                  en: 'Eg: highway and city',
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 22),
              AppleButton(
                label: context.t(
                  pt: 'Salvar abastecimento',
                  en: 'Save fuel log',
                ),
                onPressed: _salvarDados,
              ),
              const SizedBox(height: 16),
              _PlanStatusPanel(
                isLoading: _isLoadingPlanState,
                isProUnlocked: _isProUnlocked,
                savedRecordsCount: _savedRecordsCount,
                onTapLearnMore: _abrirOfertaPro,
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
                context.t(pt: 'Consumo médio', en: 'Average consumption'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _mediaConsumoNotifier,
                      builder: (context, mediaConsumo, _) {
                        return _ConsumptionMetricCard(
                          label:
                              context.t(pt: 'Média atual', en: 'Current avg'),
                          value:
                              '${context.formatNumberText(mediaConsumo)} km/L',
                          icon: CupertinoIcons.speedometer,
                          tintColor: accent,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _LimitAction { cancel, pro }

class _PlanStatusPanel extends StatelessWidget {
  const _PlanStatusPanel({
    required this.isLoading,
    required this.isProUnlocked,
    required this.savedRecordsCount,
    required this.onTapLearnMore,
  });

  final bool isLoading;
  final bool isProUnlocked;
  final int savedRecordsCount;
  final VoidCallback onTapLearnMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        isProUnlocked ? const Color(0xFF0A84FF) : const Color(0xFF30D158);
    final remainingSlots = FuelTunePlan.remainingFreeHistorySlots(
      savedRecordsCount,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isProUnlocked
                      ? FuelTunePlan.proName
                      : context.t(pt: 'Plano gratis', en: 'Free plan'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!isLoading && !isProUnlocked) ...[
                const SizedBox(width: 8),
                Text(
                  context.t(
                    pt: '$savedRecordsCount/${FuelTunePlan.freeHistoryLimit} salvos',
                    en: '$savedRecordsCount/${FuelTunePlan.freeHistoryLimit} saved',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isLoading
                ? context.t(
                    pt: 'Carregando o status do seu plano.',
                    en: 'Loading your plan status.',
                  )
                : isProUnlocked
                    ? context.t(
                        pt: 'Historico ilimitado e estatisticas do carro ficam liberados neste dispositivo.',
                        en: 'Unlimited history and car statistics are unlocked on this device.',
                      )
                    : remainingSlots > 0
                        ? context.t(
                            pt: 'Voce ainda pode salvar $remainingSlots abastecimento${remainingSlots > 1 ? 's' : ''} no plano gratis antes de conhecer o Pro.',
                            en: 'You can still save $remainingSlots fuel log${remainingSlots > 1 ? 's' : ''} on the free plan before exploring Pro.',
                          )
                        : context.t(
                            pt: 'Voce chegou ao limite do plano gratis. O Pro libera historico ilimitado e estatisticas do consumo.',
                            en: 'You reached the free plan limit. Pro unlocks unlimited history and usage statistics.',
                          ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (!isLoading && !isProUnlocked) ...[
            const SizedBox(height: 10),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onTapLearnMore,
              child: Text(
                context.t(pt: 'Conhecer o Pro', en: 'Explore Pro'),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF0A84FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConsumptionMetricCard extends StatelessWidget {
  const _ConsumptionMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tintColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: tintColor.withValues(alpha: 0.12),
        border: Border.all(color: tintColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tintColor, size: 18),
          const SizedBox(height: 14),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF30D158).withValues(alpha: 0.15),
        border: Border.all(
          color: const Color(0xFF30D158).withValues(alpha: 0.18),
        ),
      ),
      child: const Icon(CupertinoIcons.speedometer, color: Color(0xFF30D158)),
    );
  }
}
