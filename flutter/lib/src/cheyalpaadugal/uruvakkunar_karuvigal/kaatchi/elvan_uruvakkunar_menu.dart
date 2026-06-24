import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../adippadai/tharavuru/seyali_murai.dart';
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

  void _showDesignLoader() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => Scaffold(
        body: Stack(
          children: [
            AuthLayout(
              hideLogo: true,
              showBranding: true,
              child: Center(
                child: Text(
                  'niril',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 48,
              left: 24,
              child: IconButton(
                icon: const Icon(CupertinoIcons.back),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    ));
  }

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

  void _addExtraSilkProfile() async {
    // Temporarily switch to silk mode to seed the extra profile
    final currentMode = ref.read(appModeProvider);
    ref.read(appModeProvider.notifier).setMode(AppMode.silk);
    final notifier = ref.read(NiruvanaTharavugalListProvider.notifier);
    final secondProfile = mockSilkProfiles.length > 1 ? mockSilkProfiles[1] : null;
    if (secondProfile != null) {
      final profile = NiruvanaTharavugal(
        mudhanMozhi: secondProfile['mudhanMozhi'] ?? 'Tamil',
        thunaiMozhi: secondProfile['thunaiMozhi'] ?? 'English',
        iruMozhi: secondProfile['iruMozhi'] ?? true,
        niruvanathinPeyar: {
          'Tamil': secondProfile['niruvanathinPeyar_Tamil'] ?? '',
          'English': secondProfile['niruvanathinPeyar_English'] ?? '',
        },
        kurumPeyar: secondProfile['kurumPeyar'] ?? '',
        tholaipaesi1: secondProfile['tholaipesi_1'] ?? '',
        tholaipaesi2: secondProfile['tholaipesi_2'] ?? '',
        minnanjal: secondProfile['minnanjal'] ?? '',
        gstin: secondProfile['gstin'] ?? '',
        mugavari: {
          'Tamil': secondProfile['mugavari_Tamil'] ?? '',
          'English': secondProfile['mugavari_English'] ?? '',
        },
        oor: {
          'Tamil': secondProfile['oor_Tamil'] ?? '',
          'English': secondProfile['oor_English'] ?? '',
        },
        maavattam: {
          'Tamil': secondProfile['maavattam_Tamil'] ?? '',
          'English': secondProfile['maavattam_English'] ?? '',
        },
        maanilam: {
          'Tamil': secondProfile['maanilam_Tamil'] ?? '',
          'English': secondProfile['maanilam_English'] ?? '',
        },
        naadu: {
          'Tamil': secondProfile['naadu_Tamil'] ?? '',
          'English': secondProfile['naadu_English'] ?? '',
        },
        anjalKuriyeedu: secondProfile['anjalKuriyeedu'] ?? '',
        vangiPeyar: {
          'Tamil': secondProfile['vangiPeyar_Tamil'] ?? '',
          'English': secondProfile['vangiPeyar_English'] ?? '',
        },
        kilai: {
          'Tamil': secondProfile['kilai_Tamil'] ?? '',
          'English': secondProfile['kilai_English'] ?? '',
        },
        vangiKanakku: secondProfile['vangiKanakku'] ?? '',
        ifsc: secondProfile['ifsc'] ?? '',
        oavuru: secondProfile['oavuru'] ?? '',
        agalaOavuru: secondProfile['agalaOavuru'] ?? '',
        thalaippuVadivu: secondProfile['thalaippuVadivu'] ?? 'small',
        kaiyoppam: secondProfile['kaiyoppam'] ?? '',
        oppamPeyar: secondProfile['oppamPeyar'] ?? '',
        adaimozhi: {
          'Tamil': secondProfile['adaimozhi_Tamil'] ?? '',
          'English': secondProfile['adaimozhi_English'] ?? '',
        },
        upiId: secondProfile['upiId'] ?? '',
        thoatraNiram: secondProfile['thoatraNiram'] ?? '',
      );
      await notifier.createProfile(profile);
    }
    if (currentMode != null) {
      ref.read(appModeProvider.notifier).setMode(currentMode);
    }
    if (mounted) {
      ElvanSnackbar.show(context, 'Extra Silk Profile (EPS) Added ✓');
    }
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
                      heroTag: 'dev_loader',
                      onPressed: _showDesignLoader,
                      label: const Text('Design Loader'),
                      icon: const Icon(CupertinoIcons.eye),
                      backgroundColor: Colors.purple,
                    ),
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
                      heroTag: 'dev_extra_silk',
                      onPressed: _addExtraSilkProfile,
                      label: const Text('Extra Silk Biz'),
                      icon: const Icon(CupertinoIcons.add_circled),
                      backgroundColor: Colors.deepPurple,
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
