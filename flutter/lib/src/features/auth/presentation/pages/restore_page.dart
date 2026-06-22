import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../../core/services/niril_backup_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/elvan_loading_overlay.dart';
import '../../../../core/widgets/elvan_snackbar.dart';
import '../../../../core/state/app_state.dart';
import '../../../settings/data/vaniga_tharavugal_provider.dart';
import '../widgets/auth_components.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RESTORE PAGE — தரவு மீட்டெடுப்பு
// ─────────────────────────────────────────────────────────────────────────────
// Shown after login when profiles are missing but a local backup exists.
// Gives the user two choices:
//   1. Restore old data from backup
//   2. Start fresh with new business setup

class RestorePage extends ConsumerStatefulWidget {
  /// Called when the user chooses "Start Fresh" — skips restore.
  final VoidCallback onStartFresh;

  const RestorePage({super.key, required this.onStartFresh});

  @override
  ConsumerState<RestorePage> createState() => _RestorePageState();
}

class _RestorePageState extends ConsumerState<RestorePage> {
  bool _restoring = false;

  Future<void> _handleRestore() async {
    if (_restoring) return;

    setState(() => _restoring = true);

    // Show loading overlay
    if (context.mounted) {
      showElvanLoadingOverlay(
        context: context,
        text: 'restoring'.tr(context, ref),
      );
    }

    try {
      final backupService = ref.read(backupServiceProvider);

      // Close the current database connection before overwriting the file
      final db = ref.read(appDatabaseProvider);
      await db.close();

      // Restore from backup (copies backup.db → main elvan_niril.db)
      final success = await backupService.restoreFromBackup();

      if (!mounted) return;

      // Pop the loading overlay
      Navigator.of(context, rootNavigator: true).pop();

      if (success) {
        ElvanSnackbar.show(context, 'restoreSuccess'.tr(context, ref));

        // Invalidate the database provider so a brand new AppDatabase instance 
        // is created that connects to the newly restored file!
        ref.invalidate(appDatabaseProvider);
        
        // Invalidate the backup check
        ref.invalidate(hasBackupProvider);

        // Force the app state to re-evaluate by toggling mode
        ref.invalidate(appModeProvider);
      } else {
        ElvanSnackbar.show(context, 'Restore failed. Please try again.');
        setState(() => _restoring = false);
      }
    } catch (e) {
      if (!mounted) return;

      // Try to pop the loading overlay if it's still showing
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}

      ElvanSnackbar.show(context, 'Restore failed: $e');
      setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return KeyedSubtree(
      key: const ValueKey('restore_page'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          AuthAnimatedElement(
            delayIndex: 0,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.arrow_counterclockwise_circle_fill,
                  size: 48,
                  color: textColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title & Subtitle
          AuthHeader(
            title: 'oldDataFound'.tr(context, ref),
            subtitle: 'restoreOldDataSubtitle'.tr(context, ref),
          ),

          const SizedBox(height: 40),

          // Restore Button (Primary)
          AuthButton(
            text: 'restoreBtn'.tr(context, ref),
            loading: _restoring,
            onPressed: _handleRestore,
          ),

          const SizedBox(height: 16),

          // Start Fresh Button (Secondary / Text button)
          AuthAnimatedElement(
            delayIndex: 3,
            child: TextButton(
              onPressed: _restoring ? null : widget.onStartFresh,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'startFreshBtn'.tr(context, ref),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : const Color(0xFF999999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
