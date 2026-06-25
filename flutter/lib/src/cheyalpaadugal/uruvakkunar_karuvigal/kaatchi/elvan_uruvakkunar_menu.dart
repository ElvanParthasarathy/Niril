import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../adippadai/tharavuru/seyali_murai.dart';
import '../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../ulnuzhaivu/kaatchi/koorugal/ullnuzhaivu_koorugal.dart';
import '../../amaippugal/tharavu/niruvana_tharavugal.dart';
import '../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../tharavu/sodhanai_tharavu_uruvakki.dart';
import '../tharavu/sodhanai_tharavugal.dart';

/// A global floating developer menu that only appears in Debug mode.
class ElvanUruvakkunarMenu extends ConsumerStatefulWidget {
  final Widget child;

  const ElvanUruvakkunarMenu({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ElvanUruvakkunarMenu> createState() => _ElvanUruvakkunarMenuState();
}

class _ElvanUruvakkunarMenuState extends ConsumerState<ElvanUruvakkunarMenu> {
  bool _isExpanded = false;
  Offset _position = const Offset(20, 100);

  void _seedAllData() async {
    // ── Step 1: Erase existing data ──
    await SodhanaiTharavuUruvakki.eraseData(ref);

    // ── Step 2: Seed business profiles (both modes) ──
    ref.read(appModeProvider.notifier).setMode(AppMode.silk);
    await SodhanaiTharavuUruvakki.seedData(ref, AppMode.silk);
    ref.read(appModeProvider.notifier).setMode(AppMode.coolie);
    await SodhanaiTharavuUruvakki.seedData(ref, AppMode.coolie);

    // ── Step 3: Seed products & merchants (both modes) ──
    await SodhanaiTharavuUruvakki.seedPorulAndVanigar(ref);

    // ── Step 4: Seed invoices (depends on profiles, products, merchants) ──
    await SodhanaiTharavuUruvakki.seedPattiyalgal(ref);

    // ── Step 5: Seed receipts (depends on profiles, merchants) ──
    await SodhanaiTharavuUruvakki.seedPatrugal(ref);

    if (mounted) {
      ref.read(appModeProvider.notifier).setMode(AppMode.silk);
      ref.read(isLoggedInProvider.notifier).setLoggedIn(true);
      ElvanSnackbar.show(context, 'All Data Seeded Successfully ✓');
    }
  }

  void _eraseAllData() async {
    await SodhanaiTharavuUruvakki.eraseData(ref);
    ref.read(appModeProvider.notifier).setMode(null);
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  /// Toggle extra Silk profile (EPS) — add if missing, remove if exists.
  void _toggleExtraSilk() async {
    final currentMode = ref.read(appModeProvider);
    ref.read(appModeProvider.notifier).setMode(AppMode.silk);
    final notifier = ref.read(NiruvanaTharavugalListProvider.notifier);
    final profiles = ref.read(NiruvanaTharavugalListProvider);

    // Check if EPS already exists
    final existing = profiles.where((p) => p.kurumPeyar == 'EPS').firstOrNull;
    if (existing != null) {
      // Hide it instead of deleting
      await notifier.hideProfile(existing.id!);
      if (currentMode != null) {
        ref.read(appModeProvider.notifier).setMode(currentMode);
      }
      if (mounted) ElvanSnackbar.show(context, 'Silk EPS Removed ✗');
    } else {
      // Try to restore it first, if not found then add it
      final restored = await notifier.restoreProfile('EPS');
      if (!restored) {
        final data = mockSilkProfiles.length > 1 ? mockSilkProfiles[1] : null;
        if (data != null) {
          await notifier.createProfile(_profileFromMap(data));
        }
      }
      if (currentMode != null) {
        ref.read(appModeProvider.notifier).setMode(currentMode);
      }
      if (mounted) ElvanSnackbar.show(context, 'Silk EPS Added ✓');
    }
  }

  void _toggleLanguage() {
    final currentLocale = ref.read(localeProvider);
    if (currentLocale?.languageCode == 'ta') {
      ref.read(localeProvider.notifier).setLocale(const Locale('en'));
      if (mounted) ElvanSnackbar.show(context, 'Language: English');
    } else if (currentLocale?.languageCode == 'en') {
      ref.read(localeProvider.notifier).setLocale(const Locale('tg'));
      if (mounted) ElvanSnackbar.show(context, 'Language: Tanglish');
    } else {
      ref.read(localeProvider.notifier).setLocale(const Locale('ta'));
      if (mounted) ElvanSnackbar.show(context, 'மொழி: தமிழ்');
    }
  }

  /// Toggle extra Coolie profile (PVS) — add if missing, remove if exists.
  void _toggleCoolieSingle() async {
    final currentMode = ref.read(appModeProvider);
    ref.read(appModeProvider.notifier).setMode(AppMode.coolie);
    final notifier = ref.read(NiruvanaTharavugalListProvider.notifier);
    final profiles = ref.read(NiruvanaTharavugalListProvider);

    // Check if PVS exists
    final pvs = profiles.where((p) => p.kurumPeyar == 'PVS').firstOrNull;
    if (pvs != null) {
      // Hide PVS → single profile mode
      await notifier.hideProfile(pvs.id!);
      if (currentMode != null) {
        ref.read(appModeProvider.notifier).setMode(currentMode);
      }
      if (mounted) ElvanSnackbar.show(context, 'Coolie PVS Removed (1 biz) ✗');
    } else {
      // Try to restore it first, if not found then add it
      final restored = await notifier.restoreProfile('PVS');
      if (!restored) {
        final data = mockCoolieProfiles.length > 1 ? mockCoolieProfiles[1] : null;
        if (data != null) {
          await notifier.createProfile(_profileFromMap(data));
        }
      }
      if (currentMode != null) {
        ref.read(appModeProvider.notifier).setMode(currentMode);
      }
      if (mounted) ElvanSnackbar.show(context, 'Coolie PVS Added (2 biz) ✓');
    }
  }

  /// Builds a NiruvanaTharavugal from a mock map.
  NiruvanaTharavugal _profileFromMap(Map<String, dynamic> d) {
    return NiruvanaTharavugal(
      mudhanMozhi: d['mudhanMozhi'] ?? 'Tamil',
      thunaiMozhi: d['thunaiMozhi'] ?? 'English',
      iruMozhi: d['iruMozhi'] ?? true,
      niruvanathinPeyar: {
        'Tamil': d['niruvanathinPeyar_Tamil'] ?? '',
        'English': d['niruvanathinPeyar_English'] ?? '',
      },
      kurumPeyar: d['kurumPeyar'] ?? '',
      tholaipaesi1: d['tholaipesi_1'] ?? '',
      tholaipaesi2: d['tholaipesi_2'] ?? '',
      minnanjal: d['minnanjal'] ?? '',
      gstin: d['gstin'] ?? '',
      mugavari: {'Tamil': d['mugavari_Tamil'] ?? '', 'English': d['mugavari_English'] ?? ''},
      oor: {'Tamil': d['oor_Tamil'] ?? '', 'English': d['oor_English'] ?? ''},
      maavattam: {'Tamil': d['maavattam_Tamil'] ?? '', 'English': d['maavattam_English'] ?? ''},
      maanilam: {'Tamil': d['maanilam_Tamil'] ?? '', 'English': d['maanilam_English'] ?? ''},
      naadu: {'Tamil': d['naadu_Tamil'] ?? '', 'English': d['naadu_English'] ?? ''},
      anjalKuriyeedu: d['anjalKuriyeedu'] ?? '',
      vangiPeyar: {'Tamil': d['vangiPeyar_Tamil'] ?? '', 'English': d['vangiPeyar_English'] ?? ''},
      kilai: {'Tamil': d['kilai_Tamil'] ?? '', 'English': d['kilai_English'] ?? ''},
      vangiKanakku: d['vangiKanakku'] ?? '',
      ifsc: d['ifsc'] ?? '',
      oavuru: d['oavuru'] ?? '',
      agalaOavuru: d['agalaOavuru'] ?? '',
      thalaippuVadivu: d['thalaippuVadivu'] ?? 'small',
      kaiyoppam: d['kaiyoppam'] ?? '',
      oppamPeyar: d['oppamPeyar'] ?? '',
      adaimozhi: {'Tamil': d['adaimozhi_Tamil'] ?? '', 'English': d['adaimozhi_English'] ?? ''},
      upiId: d['upiId'] ?? '',
      thoatraNiram: d['thoatraNiram'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    // If not in debug mode, simply return the app
    if (!kDebugMode) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _position += details.delta;
              });
            },
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FloatingActionButton(
                    heroTag: 'dev_menu_toggle',
                    mini: true,
                    backgroundColor: Colors.black87,
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: const Icon(Icons.developer_mode, color: Colors.white),
                  ),
                  if (_isExpanded) ...[

                    const SizedBox(height: 8),
                    FloatingActionButton.extended(
                      heroTag: 'dev_seed',
                      onPressed: _seedAllData,
                      label: const Text('Seed All'),
                      icon: const Icon(CupertinoIcons.rocket),
                      backgroundColor: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.extended(
                      heroTag: 'dev_erase',
                      onPressed: _eraseAllData,
                      label: const Text('Erase Data'),
                      icon: const Icon(CupertinoIcons.trash),
                      backgroundColor: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.extended(
                      heroTag: 'dev_toggle_silk',
                      onPressed: _toggleExtraSilk,
                      label: const Text('Toggle Silk ±EPS'),
                      icon: const Icon(CupertinoIcons.repeat),
                      backgroundColor: Colors.deepPurple,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.extended(
                      heroTag: 'dev_toggle_coolie',
                      onPressed: _toggleCoolieSingle,
                      label: const Text('Toggle Coolie ±PVS'),
                      icon: const Icon(CupertinoIcons.repeat),
                      backgroundColor: Colors.teal,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.extended(
                      heroTag: 'dev_toggle_lang',
                      onPressed: _toggleLanguage,
                      label: const Text('Toggle UI Lang'),
                      icon: const Icon(Icons.language),
                      backgroundColor: Colors.blueAccent,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
