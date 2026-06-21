import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import 'elvan_settings_section.dart';
import '../../../../core/widgets/elvan_text_field.dart';
import '../../../../core/widgets/elvan_action_sheet.dart';
import '../../../../core/widgets/elvan_loading_overlay.dart';
import '../../../../core/widgets/elvan_snackbar.dart';
import '../../../../core/preferences_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/database/app_database.dart';
import '../../data/vaniga_tharavugal_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';

class AccountSecuritySection extends ConsumerWidget {
  const AccountSecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final iconBgColor = theme.colorScheme.onSurface.withValues(alpha: 0.05);

    return ElvanSettingsSection(
      children: [
        ElvanSettingsRow(
          iconWidget: Icon(
            CupertinoIcons.square_arrow_right_fill,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          iconBgColor: iconBgColor,
          title: 'logout'.tr(context, ref),
          description: 'logout_desc'.tr(context, ref),
          onTap: () {
            _showSignOutFlow(context, ref);
          },
        ),
        ElvanSettingsRow(
          iconWidget: Icon(
            CupertinoIcons.delete_solid,
            color: theme.colorScheme.error,
            size: 20,
          ),
          iconBgColor: theme.colorScheme.error.withValues(alpha: 0.1),
          title: 'erase_data'.tr(context, ref),
          description: 'erase_data_desc'.tr(context, ref),
          onTap: () {
            _showEraseDataFlow(context, ref);
          },
        ),
      ],
    );
  }

  void _showSignOutFlow(BuildContext context, WidgetRef ref) {
    showElvanActionSheet(
      context: context,
      title: 'signOutConfirmTitle'.tr(context, ref),
      cancelText: 'cancel'.tr(context, ref),
      confirmText: 'signOutBtn'.tr(context, ref),
      onConfirm: () {
        // Mock Sign Out
        showElvanLoadingOverlay(context: context, text: 'signing_out'.tr(context, ref));
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.pop(context); // close loader
            Navigator.pop(context); // close action sheet
            // In a real app, this would clear auth and redirect
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
              (route) => false,
            );
            ElvanSnackbar.show(context, 'signOutSuccess'.tr(context, ref));
          }
        });
      },
    );
  }

  void _showEraseDataFlow(BuildContext context, WidgetRef ref) {
    // Step 1: Email Confirmation
    showElvanActionSheet(
      context: context,
      title: 'eraseAppDataTitle'.tr(context, ref),
      cancelText: 'cancel'.tr(context, ref),
      confirmText: 'continue'.tr(context, ref),
      customContent: ElvanTextField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'confirmEmailLabel'.tr(context, ref),
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
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onConfirm: () {
        // Step 2: Password Confirmation
        showElvanActionSheet(
          context: context,
          title: 'enterPassword'.tr(context, ref),
          cancelText: 'cancel'.tr(context, ref),
          confirmText: 'eraseDataBtn'.tr(context, ref),
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
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onConfirm: () async {
            // Step 3: Show Loading Animation
            showElvanLoadingOverlay(context: context, text: 'erasing'.tr(context, ref));

            // Simulate erasing delay
            await Future.delayed(const Duration(seconds: 2));
            
            if (context.mounted) {
              // Close loader
              Navigator.pop(context);
              // Close password sheet
              Navigator.pop(context);
              // Close email sheet
              Navigator.pop(context);
              
              // Wipe local DB profiles
              final db = ref.read(appDatabaseProvider);
              await db.delete(db.vanigaTharavugalTable).go();
              
              // Clear SharedPreferences
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.clear();

              if (context.mounted) {
                // Mock fresh install redirect by resetting mode
                ref.invalidate(appModeProvider);
                ref.invalidate(appDatabaseProvider);
                Navigator.popUntil(context, (route) => route.isFirst);
                ElvanSnackbar.show(context, 'dataErasedSuccess'.tr(context, ref));
              }
            }
          },
        );
      },
    );
  }
}
