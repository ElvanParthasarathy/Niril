import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_marabu.dart';

/// A standard pill-shaped text field component designed specifically for Elvan Editors (Thiruthi).
/// It visually matches the standard Keezhvirivu (Dropdown) and other editor components.
class ElvanThiruthiUlleedu extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String? suffixText;
  final String? errorText;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final String? hintText;

  const ElvanThiruthiUlleedu({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.prefixText,
    this.suffixText,
    this.errorText,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          focusNode: focusNode,
          enabled: enabled,
          autofocus: autofocus,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            constraints: (maxLines == null || maxLines! > 1) 
                ? ElvanThiruthiMarabu.multiLineConstraints 
                : ElvanThiruthiMarabu.singleLineConstraints,
            isDense: true,
            prefixText: prefixText,
            suffixText: suffixText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            hintText: hintText,
            filled: true,
            fillColor: ElvanThiruthiMarabu.buildFillColor(context),
            contentPadding: ElvanThiruthiMarabu.contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ElvanThiruthiMarabu.borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ElvanThiruthiMarabu.borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ElvanThiruthiMarabu.borderRadius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
