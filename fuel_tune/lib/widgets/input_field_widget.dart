import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tune/l10n/app_language_scope.dart';

class InputFieldWidget extends StatefulWidget {
  const InputFieldWidget({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.onEditingComplete,
    this.onChanged,
    this.focusNode,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.textInputAction,
    this.maxLines = 1,
    this.prefixText,
    this.suffixText,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? prefixText;
  final String? suffixText;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  State<InputFieldWidget> createState() => _InputFieldWidgetState();
}

class _InputFieldWidgetState extends State<InputFieldWidget> {
  FocusNode? _internalFocusNode;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;

  bool get _usesNumericKeyboard =>
      widget.keyboardType.index == TextInputType.number.index;

  bool get _showDoneButton =>
      widget.maxLines == 1 &&
      _usesNumericKeyboard &&
      _effectiveFocusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _attachFocusNode();
  }

  @override
  void didUpdateWidget(covariant InputFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode(oldWidget.focusNode ?? _internalFocusNode);
      _attachFocusNode();
    }
  }

  @override
  void dispose() {
    _detachFocusNode(_effectiveFocusNode);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _attachFocusNode() {
    _internalFocusNode ??= widget.focusNode == null ? FocusNode() : null;
    _effectiveFocusNode.addListener(_handleFocusChanged);
  }

  void _detachFocusNode(FocusNode? focusNode) {
    focusNode?.removeListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _handleDonePressed() {
    widget.onEditingComplete?.call();
    _effectiveFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: CupertinoTextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            onEditingComplete: widget.onEditingComplete,
            onChanged: widget.onChanged,
            focusNode: _effectiveFocusNode,
            maxLines: widget.maxLines,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            autocorrect: widget.autocorrect,
            enableSuggestions: widget.enableSuggestions,
            placeholder: widget.hintText,
            onTapOutside: (_) => _effectiveFocusNode.unfocus(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            prefix: widget.prefixText == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      widget.prefixText!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
            suffix: _buildSuffix(context, theme, colorScheme),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            placeholderStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            decoration: null,
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffix(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (widget.suffixText == null && !_showDoneButton) {
      return null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.suffixText != null)
          Padding(
            padding: EdgeInsets.only(
              left: _showDoneButton ? 8 : 0,
              right: _showDoneButton ? 8 : 16,
            ),
            child: Text(
              widget.suffixText!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (_showDoneButton)
          Padding(
            padding: EdgeInsets.only(
              right: widget.suffixText == null ? 8 : 12,
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              onPressed: _handleDonePressed,
              child: Text(
                context.t(pt: 'Concluir', en: 'Done'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
