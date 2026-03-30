import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tune/config/fuel_tune_plan.dart';
import 'package:fuel_tune/l10n/app_language.dart';
import 'package:fuel_tune/l10n/app_language_scope.dart';
import 'package:fuel_tune/l10n/language_controller.dart';
import 'package:fuel_tune/repositories/fuel_record_repository.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';
import 'package:fuel_tune/screens/premium/premium_insights_page.dart';
import 'package:fuel_tune/services/pro_access_service.dart';
import 'package:fuel_tune/theme/theme_controller.dart';
import 'package:fuel_tune/widgets/apple_page_layout.dart';
import 'package:fuel_tune/widgets/apple_section_card.dart';
import 'package:fuel_tune/widgets/apple_button.dart';
import 'package:fuel_tune/widgets/fuel_tune_pro_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.themeController,
    required this.languageController,
    this.appStateVersion,
  });

  final ThemeController themeController;
  final LanguageController languageController;
  final ValueNotifier<int>? appStateVersion;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LocalPreferencesRepository _preferencesRepository =
      LocalPreferencesRepository();
  final FuelRecordRepository _recordRepository = FuelRecordRepository();
  final ProAccessService _proAccessService = ProAccessService();

  int? _storageSizeBytes;
  bool _isProUnlocked = false;

  @override
  void initState() {
    super.initState();
    widget.appStateVersion?.addListener(_handleExternalAppStateChange);
    _calcularTamanhoArmazenamento();
    _carregarPlano();
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
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
    _calcularTamanhoArmazenamento();
    _carregarPlano();
  }

  Future<void> _calcularTamanhoArmazenamento() async {
    final totalSize =
        await _preferencesRepository.calculateStorageUsageInBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      _storageSizeBytes = totalSize;
    });
  }

  Future<void> _carregarPlano() async {
    final isProUnlocked = await _preferencesRepository.loadIsProUnlocked();

    if (!mounted) {
      return;
    }

    setState(() {
      _isProUnlocked = isProUnlocked;
    });
  }

  Future<void> _limparDadosSalvos() async {
    final shouldClear = await showCupertinoDialog<bool>(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(
                context.t(
                  pt: 'Limpar histórico?',
                  en: 'Clear history?',
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  context.t(
                    pt: 'Isso vai apagar os abastecimentos salvos localmente. O tema escolhido será mantido.',
                    en: 'This will remove the fueling records saved on this device. Your selected theme will stay the same.',
                  ),
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(context.t(pt: 'Cancelar', en: 'Cancel')),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(context.t(pt: 'Limpar', en: 'Clear')),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldClear) {
      return;
    }

    await _recordRepository.clearRecords();
    await _calcularTamanhoArmazenamento();

    if (!mounted) {
      return;
    }

    if (widget.appStateVersion != null) {
      widget.appStateVersion!.value++;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.t(
            pt: 'Histórico apagado com sucesso.',
            en: 'History cleared successfully.',
          ),
        ),
      ),
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
    await _carregarPlano();

    if (widget.appStateVersion != null) {
      widget.appStateVersion!.value++;
    }
  }

  Future<void> _ativarProModoDebug() async {
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

  Future<void> _abrirPainelPremium() async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => PremiumInsightsPage(
          appStateVersion: widget.appStateVersion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF8E8E93);

    return ApplePageLayout(
      title: context.t(pt: 'Configurações', en: 'Settings'),
      subtitle: context.t(
        pt: 'Escolha a aparência do app, o idioma e mantenha seus dados locais sob controle.',
        en: 'Choose the app appearance, the language, and keep your local data under control.',
      ),
      accentColor: accent,
      trailing: const _SettingsBadge(),
      children: [
        AppleSectionCard(
          tintColor: const Color(0xFF0A84FF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t(pt: 'Plano', en: 'Plan'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (_isProUnlocked
                          ? const Color(0xFF0A84FF)
                          : const Color(0xFF8E8E93))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _isProUnlocked
                      ? FuelTunePlan.proName
                      : context.t(pt: 'Plano gratis', en: 'Free plan'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _isProUnlocked
                            ? const Color(0xFF0A84FF)
                            : const Color(0xFF8E8E93),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isProUnlocked
                    ? context.t(
                        pt: 'Historico ilimitado e futuras melhorias premium estao ativos neste dispositivo.',
                        en: 'Unlimited history and future premium improvements are active on this device.',
                      )
                    : context.t(
                        pt: 'No plano gratis, voce pode salvar ate ${FuelTunePlan.freeHistoryLimit} abastecimentos. O Pro libera historico ilimitado e estatisticas do consumo.',
                        en: 'On the free plan, you can save up to ${FuelTunePlan.freeHistoryLimit} fuel logs. Pro unlocks unlimited history and usage statistics.',
                      ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _abrirPainelPremium,
                child: Text(
                  _isProUnlocked
                      ? context.t(
                          pt: 'Abrir painel premium', en: 'Open premium panel')
                      : context.t(
                          pt: 'Ver painel premium', en: 'View premium panel'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF0A84FF),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (!_isProUnlocked)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _abrirOfertaPro,
                  child: Text(
                    context.t(pt: 'Conhecer o Pro', en: 'Explore Pro'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              if (!_isProUnlocked && kDebugMode) ...[
                const SizedBox(height: 12),
                AppleButton(
                  label: context.t(
                    pt: 'Ativar Pro no modo debug',
                    en: 'Enable Pro in debug mode',
                  ),
                  onPressed: _ativarProModoDebug,
                ),
              ],
            ],
          ),
        ),
        AppleSectionCard(
          tintColor: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t(pt: 'Idioma', en: 'Language'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: widget.languageController,
                builder: (context, _) {
                  return CupertinoSlidingSegmentedControl<AppLanguage>(
                    groupValue: widget.languageController.language,
                    children: const {
                      AppLanguage.portuguese: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Text('Português'),
                      ),
                      AppLanguage.english: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Text('English'),
                      ),
                    },
                    onValueChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      widget.languageController.updateLanguage(value);
                    },
                  );
                },
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
                context.t(pt: 'Tema', en: 'Theme'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: widget.themeController,
                builder: (context, _) {
                  return CupertinoSlidingSegmentedControl<ThemeMode>(
                    groupValue: widget.themeController.themeMode,
                    children: {
                      ThemeMode.light: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Text(context.t(pt: 'Claro', en: 'Light')),
                      ),
                      ThemeMode.dark: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Text(context.t(pt: 'Escuro', en: 'Dark')),
                      ),
                    },
                    onValueChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      widget.themeController.updateThemeMode(value);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                context.t(
                  pt: 'Os nomes do seletor seguem o idioma escolhido no app.',
                  en: 'The selector labels follow the language chosen in the app.',
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
                context.t(pt: 'Dados locais', en: 'Local data'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                _storageSizeBytes == null
                    ? context.t(pt: 'Calculando...', en: 'Calculating...')
                    : context.t(
                        pt: 'Uso de armazenamento: ${context.formatStorageSizeText(_storageSizeBytes!)}',
                        en: 'Storage usage: ${context.formatStorageSizeText(_storageSizeBytes!)}',
                      ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 18),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _limparDadosSalvos,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.delete_solid,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.t(
                            pt: 'Limpar abastecimentos salvos',
                            en: 'Clear saved fuel logs',
                          ),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: Colors.red,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsBadge extends StatelessWidget {
  const _SettingsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF8E8E93).withValues(alpha: 0.16),
        border: Border.all(
          color: const Color(0xFF8E8E93).withValues(alpha: 0.18),
        ),
      ),
      child: const Icon(
        CupertinoIcons.settings_solid,
        color: Color(0xFF8E8E93),
      ),
    );
  }
}
