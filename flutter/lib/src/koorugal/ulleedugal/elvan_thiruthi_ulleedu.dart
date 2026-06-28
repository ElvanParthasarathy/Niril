import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thooiya_ulleedu.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_thalaippu.dart';

/// A standard pill-shaped text field component designed specifically for Elvan Editors (Thiruthi).
/// Uses ElvanThooiyaUlleedu to bypass InputDecoration constraints, offering perfect 45px vertical centering.
class ElvanThiruthiUlleedu extends StatelessWidget {
  final String? label;
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
  final bool readOnly;
  final VoidCallback? onTap;

  const ElvanThiruthiUlleedu({
    super.key,
    this.label,
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
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSingleLine = maxLines == 1;
    final borderRadius = isSingleLine ? 100.0 : 16.0;
    final cs = Theme.of(context).colorScheme;

    // The raw text field without any padding or decorations
    final rawInput = ElvanThooiyaUlleedu(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      maxLength: maxLength,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
    );

    // Build the custom input area
    Widget inputArea;
    if (isSingleLine) {
      inputArea = SizedBox(
        height: 45.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              const SizedBox(width: 8),
            ] else
              const SizedBox(width: 20),
            
            if (prefixText != null) ...[
              Text(prefixText!, style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
              const SizedBox(width: 4),
            ],

            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Hint Text
                  if (hintText != null)
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller ?? TextEditingController(),
                      builder: (context, value, child) {
                        if (value.text.isEmpty && (initialValue == null || initialValue!.isEmpty)) {
                          return Text(
                            hintText!,
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurface.withValues(alpha: 0.4),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  // Raw Editable Text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: rawInput,
                  ),
                ],
              ),
            ),

            if (suffixText != null) ...[
              const SizedBox(width: 4),
              Text(suffixText!, style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
            ],

            if (suffixIcon != null) ...[
              const SizedBox(width: 8),
              suffixIcon!,
            ] else
              const SizedBox(width: 20),
          ],
        ),
      );
    } else {
      inputArea = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            if (hintText != null)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller ?? TextEditingController(),
                builder: (context, value, child) {
                  if (value.text.isEmpty && (initialValue == null || initialValue!.isEmpty)) {
                    return Text(
                      hintText!,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            rawInput,
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ElvanThiruthiThalaippu(label: label!),
        Material(
          color: cs.onSurface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(borderRadius),
          clipBehavior: Clip.antiAlias,
          child: inputArea,
        ),
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText!,
              style: TextStyle(
                color: cs.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
