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
import '../../../../core/theme_provider.dart';
import '../../../../core/services/niril_backup_service.dart';
import '../../data/vaniga_tharavugal_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/welcome_page.dart';

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
            CupertinoIcons.cloud_upload_fill,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          iconBgColor: iconBgColor,
          title: 'backup_now'.tr(context, ref),
          description: 'backup_now_desc'.tr(context, ref),
          onTap: () {
            _showBackupFlow(context, ref);
          },
        ),
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

  void _showBackupFlow(BuildContext context, WidgetRef ref) {
    showElvanActionSheet(
      context: context,
      title: 'backup_now_title'.tr(context, ref),
      cancelText: 'cancelBtn'.tr(context, ref),
      confirmText: 'backup_now_btn'.tr(context, ref),
      onConfirm: () async {
        showElvanLoadingOverlay(
            context: context, text: 'backing_up'.tr(context, ref));
            
        // Wait a small amount of time for UX purposes so it doesn't flash instantly
        await Future.delayed(const Duration(milliseconds: 800));
        
        final backupService = ref.read(backupServiceProvider);
        await backupService.createBackup();

        if (context.mounted) {
          // Pop the loading dialog
          Navigator.of(context, rootNavigator: true).pop();
          ElvanSnackbar.show(context, 'backup_success'.tr(context, ref));
        }
      },
    );
  }

  void _showSignOutFlow(BuildContext context, WidgetRef ref) {
    showElvanActionSheet(
      context: context,
      title: 'signOutConfirmTitle'.tr(context, ref),
      cancelText: 'cancelBtn'.tr(context, ref),
      confirmText: 'signOutBtn'.tr(context, ref),
      onConfirm: () {
        // Mock Sign Out
        showElvanLoadingOverlay(
            context: context, text: 'signing_out'.tr(context, ref));
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            final successMsg = 'signOutSuccess'.tr(context, ref);
            
            // Show snackbar first before we unmount this context
            ElvanSnackbar.show(context, successMsg);
            
            // Update global state
            ref.read(appModeProvider.notifier).setMode(null);
            ref.read(isLoggedInProvider.notifier).setLoggedIn(false);

            // Instantly wipe in-memory settings so UI snaps back to default
            ref.invalidate(themeModeProvider);
            ref.invalidate(localeProvider);

            // Pop all dialogs and screens back to the root route.
            Navigator.of(context, rootNavigator: true)
                .popUntil((route) => route.isFirst);
          }
        });
      },
    );
  }

  void _showEraseDataFlow(BuildContext context, WidgetRef ref) {
    // Step 1: Email Confirmation
    showElvanActionSheet(
      context: context,
      title: 'erase_data'.tr(context, ref),
      cancelText: 'cancelBtn'.tr(context, ref),
      confirmText: 'continue'.tr(context, ref),
      customContent: ElvanTextField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'confirmEmailLabel'.tr(context, ref),
          hintStyle: TextStyle(
            fontSize: 13,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          filled: true,
          fillColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.12);
            }
            return Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.08);
          }),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          cancelText: 'cancelBtn'.tr(context, ref),
          confirmText: 'eraseDataBtn'.tr(context, ref),
          customContent: ElvanTextField(
            textAlign: TextAlign.center,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'password'.tr(context, ref),
              hintStyle: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.12);
                }
                return Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08);
              }),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            showElvanLoadingOverlay(
                context: context, text: 'erasing'.tr(context, ref));

            // Simulate erasing delay
            await Future.delayed(const Duration(seconds: 2));

            if (context.mounted) {
              // We do not manually pop dialogs here, as that triggers overlapping
              // pop animations that crash the Navigator (!_debugLocked).
              // pushAndRemoveUntil below will cleanly destroy all dialogs instantly.

              // Wipe local DB profiles
              final db = ref.read(appDatabaseProvider);
              await db.delete(db.vanigaTharavugalTable).go();

              // Clear SharedPreferences
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.clear();

              if (context.mounted) {
                final successMsg = 'dataErasedSuccess'.tr(context, ref);

                // Show snackbar first before we unmount this context
                ElvanSnackbar.show(context, successMsg);

                // Mock fresh install redirect by resetting mode and auth
                ref.read(appModeProvider.notifier).setMode(null);
                ref.read(isLoggedInProvider.notifier).setLoggedIn(false);

                // Instantly wipe in-memory settings so UI snaps back to default
                ref.invalidate(themeModeProvider);
                ref.invalidate(localeProvider);
                ref.invalidate(skipRestoreProvider);

                // Pop all dialogs and screens back to the root route.
                Navigator.of(context, rootNavigator: true)
                    .popUntil((route) => route.isFirst);
              }
            }
          },
        );
      },
    );
  }
}
