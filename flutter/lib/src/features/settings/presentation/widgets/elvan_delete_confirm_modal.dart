import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/localization/locale_provider.dart';
import 'package:elvan_niril/src/core/widgets/elvan_text_field.dart';
import '../../../../core/widgets/elvan_action_sheet.dart';

void showElvanDeleteConfirmModal(BuildContext context, WidgetRef ref, VoidCallback onDelete) {
  showElvanActionSheet(
    context: context,
    title: 'permanentlyDeleteProfile'.tr(context, ref),
    cancelText: 'cancelBtn'.tr(context, ref),
    confirmText: 'deleteBtn'.tr(context, ref),
    customContent: ElvanTextField(
      textAlign: TextAlign.center,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'password'.tr(context, ref),
        hintStyle: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        filled: true,
        fillColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);
          }
          return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
        }),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
    onConfirm: onDelete,
  );
}
