import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../../core/preferences_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/niril_backup_service.dart';
import '../../../settings/data/vaniga_tharavugal_provider.dart';
import 'package:drift/drift.dart' hide Column;
import '../mode_selector_screen.dart';
import '../widgets/auth_components.dart';

class VanakkamPage extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final String billingLanguage;
  const VanakkamPage({super.key, required this.billingLanguage, this.onBack});

  @override
  ConsumerState<VanakkamPage> createState() => _VanakkamPageState();
}

class _VanakkamPageState extends ConsumerState<VanakkamPage> {
  String _gstBusinessName = '';
  String _coolieBusinessName = '';
  bool _saving = false;

  bool get _needsSilk => ref.read(missingProfilesProvider).contains('silk');
  bool get _needsCoolie => ref.read(missingProfilesProvider).contains('coolie');

  void _handleFinish() async {
    if ((_needsSilk && _gstBusinessName.trim().isEmpty) ||
        (_needsCoolie && _coolieBusinessName.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter all required business names.')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    // Mock save delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Insert initial profiles into the database
    final db = ref.read(appDatabaseProvider);

    // Insert Silk profile if needed
    if (_needsSilk) {
      await db.into(db.vanigaTharavugalTable).insert(
            VanigaTharavugalTableCompanion.insert(
              seyaliVagai: 'silk',
              niruvanathinPeyar:
                  Value({widget.billingLanguage: _gstBusinessName}),
              mudhanMozhi: Value(widget.billingLanguage),
              thunaiMozhi: Value(
                  widget.billingLanguage == 'English' ? 'Tamil' : 'English'),
              iruMozhi: const Value(true), // default bilingual on for silk
            ),
          );
    }

    // Insert Coolie profile if needed
    if (_needsCoolie) {
      await db.into(db.vanigaTharavugalTable).insert(
            VanigaTharavugalTableCompanion.insert(
              seyaliVagai: 'coolie',
              niruvanathinPeyar:
                  Value({widget.billingLanguage: _coolieBusinessName}),
              mudhanMozhi: Value(widget.billingLanguage),
            ),
          );
    }

    // Trigger an immediate backup so the initial setup is saved safely
    final backupService = ref.read(backupServiceProvider);
    await backupService.createBackup();

    if (!mounted) return;

    // Trigger router re-evaluation by setting Mode to null
    // The declarative router in main.dart will instantly catch it and send us to ModeSelectorScreen
    ref.read(appModeProvider.notifier).setMode(null);
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider)?.languageCode ?? 'en';

    return KeyedSubtree(
      key: const ValueKey('businessName'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.onBack != null) AuthBackButton(onPressed: widget.onBack!),
          AuthHeader(
            title: 'tharavugalaiUlliduga'.tr(context, ref),
            subtitle: '',
          ),
          const SizedBox(height: 32),
          if (_needsSilk)
            AuthInput(
              label: 'hc_businessName'.tr(context, ref).isNotEmpty
                  ? 'hc_businessName'.tr(context, ref)
                  : 'GST Business Name',
              placeholder: 'peyaraiUlliduga'.tr(context, ref),
              helperText: 'gstPattiyalukkuPayanpadum'.tr(context, ref),
              value: _gstBusinessName,
              onChange: (val) => setState(() => _gstBusinessName = val),
            ),
          if (_needsCoolie)
            AuthInput(
              label: 'coolieVanigaPeyar'.tr(context, ref),
              placeholder: 'peyaraiUlliduga'.tr(context, ref),
              helperText:
                  'cooliePattiyalMatrumRaseethukkuPayanpadum'.tr(context, ref),
              value: _coolieBusinessName,
              onChange: (val) => setState(() => _coolieBusinessName = val),
            ),
          const SizedBox(height: 32),
          AuthButton(
            text: 'continue'.tr(context, ref),
            loading: _saving,
            disabled: (_needsSilk && _gstBusinessName.trim().isEmpty) ||
                (_needsCoolie && _coolieBusinessName.trim().isEmpty),
            onPressed: _handleFinish,
          ),
        ],
      ),
    );
  }
}
