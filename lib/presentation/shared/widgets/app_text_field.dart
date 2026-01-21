import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.obscureText = false,
    this.enableObscureToggle,
    this.readOnly = false,
    this.enabled = true,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
  }) : assert(controller == null || initialValue == null,
            'Provide either controller or initialValue, not both.');

  final String label;
  final TextEditingController? controller;
  final String? initialValue;

  final String? hintText;
  final String? helperText;
  final String? errorText;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool? enableObscureToggle;
  final bool readOnly;
  final bool enabled;
  final Iterable<String>? autofillHints;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final int? minLines;
  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canToggle = widget.enableObscureToggle ?? (widget.obscureText && widget.suffixIcon == null);

    Widget? suffixIcon = widget.suffixIcon;
    if (canToggle) {
      suffixIcon = IconButton(
        tooltip: _obscured ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: suffixIcon,
          ),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
        ),
      ],
    );
  }
}


