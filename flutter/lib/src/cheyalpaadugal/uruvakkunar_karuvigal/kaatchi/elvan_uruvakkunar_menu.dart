import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../main.dart'; // For Route Access if needed
import '../../../adippadai/nilaimai/app_state.dart';
import '../../../adippadai/tharavuru/app_mode.dart';
import '../../../koorugal/podhu_koorugal/elvan_siruseidhi.dart';
import '../../ullnuzhaivu/kaatchi/koorugal/ullnuzhaivu_koorugal.dart';
import '../tharavu/sodhanai_tharavu_uruvakki.dart';

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
    // Seed Silk Mode
    ref.read(appModeProvider.notifier).setMode(AppMode.silk);
    await SodhanaiTharavuUruvakki.seedData(ref, AppMode.silk);

    // Seed Coolie Mode
    ref.read(appModeProvider.notifier).setMode(AppMode.coolie);
    await SodhanaiTharavuUruvakki.seedData(ref, AppMode.coolie);

    if (mounted) {
      ref.read(appModeProvider.notifier).setMode(AppMode.silk);
      ref.read(isLoggedInProvider.notifier).setLoggedIn(true);
      ElvanSnackbar.show(context, 'Test Data Seeded Successfully');
    }
  }

  void _eraseAllData() async {
    await SodhanaiTharavuUruvakki.eraseData(ref);
    ref.read(appModeProvider.notifier).setMode(null);
    Navigator.popUntil(context, (route) => route.isFirst);
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
                      label: const Text('Seed Data'),
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
