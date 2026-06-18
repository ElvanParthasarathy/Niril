import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../localization/locale_provider.dart';
import '../../../../settings/presentation/settings_screen.dart';
import 'elvan_top_bar_icon.dart';

/// A highly optimized custom popup component.
/// Completely bypasses Material's PopupMenuButton to provide precise styling,
/// animations, and zero-padding logic.
class ElvanPopupMenu extends ConsumerStatefulWidget {
  const ElvanPopupMenu({super.key});

  @override
  ConsumerState<ElvanPopupMenu> createState() => _ElvanPopupMenuState();
}

class _ElvanPopupMenuState extends ConsumerState<ElvanPopupMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _showMenu();
    }
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  void _showMenu() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible dismiss layer covering the whole screen
          // We use a translucent Listener instead of GestureDetector so that the touch event
          // physically passes through this layer down to the ScrollView beneath it!
          // This allows the user to scroll or tap the background while closing the popup seamlessly.
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => _closeMenu(),
              child: Container(),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(-220 + size.width, size.height + 16), // Position below and aligned right with new width
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.95 + (0.05 * value),
                    alignment: Alignment.topRight,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 220, // Increased width to prevent text overflow in other languages
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF2A2A2A) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          _closeMenu();
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.settings, size: 20),
                              const SizedBox(width: 12),
                              Text('settings'.tr(context, ref), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: ElvanTopBarIcon(
        icon: CupertinoIcons.ellipsis_vertical,
        onTap: _toggleMenu,
      ),
    );
  }
}