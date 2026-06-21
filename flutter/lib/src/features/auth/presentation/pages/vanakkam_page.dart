import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/locale_provider.dart';
import '../../../../core/preferences_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/database/app_database.dart';
import '../../../settings/data/vaniga_tharavugal_provider.dart';
import 'package:drift/drift.dart' hide Column;
import '../mode_selector_screen.dart';
import '../widgets/auth_components.dart';

class VanakkamPage extends ConsumerStatefulWidget {
  const VanakkamPage({super.key});

  @override
  ConsumerState<VanakkamPage> createState() => _VanakkamPageState();
}

class _VanakkamPageState extends ConsumerState<VanakkamPage> {
  String _gstBusinessName = '';
  String _coolieBusinessName = '';
  bool _saving = false;

  void _handleFinish() async {
    if (_gstBusinessName.trim().isEmpty || _coolieBusinessName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both business names.')),
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
    
    // Insert Silk profile
    await db.into(db.vanigaTharavugalTable).insert(
      VanigaTharavugalTableCompanion.insert(
        seyaliVagai: 'silk',
        niruvanathinPeyar: Value({'Tamil': _gstBusinessName, 'English': _gstBusinessName}),
      ),
    );

    // Insert Coolie profile
    await db.into(db.vanigaTharavugalTable).insert(
      VanigaTharavugalTableCompanion.insert(
        seyaliVagai: 'coolie',
        niruvanathinPeyar: Value({'Tamil': _coolieBusinessName, 'English': _coolieBusinessName}),
      ),
    );

    if (!mounted) return;

    // Route to Mode Selector
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ModeSelectorScreen(
          onModeSelected: (newMode) {
            ref.read(appModeProvider.notifier).setMode(newMode);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider)?.languageCode ?? 'en';

    return AuthLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AuthHeader(
            title: language == 'ta' ? 'தரவுகளை உள்ளிடுக' : 'Enter Business Details',
            subtitle: '',
          ),
          
          const SizedBox(height: 32),

          AuthInput(
            label: 'hc_businessName'.tr(context, ref).isNotEmpty ? 'hc_businessName'.tr(context, ref) : 'GST Business Name',
            placeholder: language == 'ta' ? 'பெயரை உள்ளிடுக' : 'Enter name',
            helperText: 'Used for regular GST invoices.',
            value: _gstBusinessName,
            onChange: (val) => setState(() => _gstBusinessName = val),
          ),

          AuthInput(
            label: language == 'ta' ? 'கூலி வணிகப் பெயர்' : 'Coolie Business Name',
            placeholder: language == 'ta' ? 'பெயரை உள்ளிடுக' : 'Enter name',
            helperText: 'Used for Coolie bills and receipts.',
            value: _coolieBusinessName,
            onChange: (val) => setState(() => _coolieBusinessName = val),
          ),

          const SizedBox(height: 32),

          AuthButton(
            text: language == 'ta' ? 'தொடரவும்' : 'Continue',
            loading: _saving,
            disabled: _gstBusinessName.trim().isEmpty || _coolieBusinessName.trim().isEmpty,
            onPressed: _handleFinish,
          ),
        ],
      ),
    );
  }
}
