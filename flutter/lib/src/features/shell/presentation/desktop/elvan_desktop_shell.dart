import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../localization/locale_provider.dart';
import '../../../../core/models/app_mode.dart';
import '../../../../core/state/app_state.dart';
import '../mobile/elvan_navbar.dart'; // For CustomNavItem
import 'elvan_desktop_sidebar.dart';

class ElvanDesktopShell extends ConsumerStatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<CustomNavItem> navItems;
  final List<Widget> slivers; // The pages (SliverOffstage)

  const ElvanDesktopShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.navItems,
    required this.slivers,
  });

  @override
  ConsumerState<ElvanDesktopShell> createState() => _ElvanDesktopShellState();
}

class _ElvanDesktopShellState extends ConsumerState<ElvanDesktopShell> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111111) : const Color(0xFFFFFFFF),
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: const Cubic(0.2, 0.0, 0.0, 1.0),
            width: isCollapsed ? 80 : 260,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111111) : const Color(0xFFFFFFFF),
              border: Border(
                right: BorderSide(
                  color: isDark ? Colors.transparent : const Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
            ),
            child: ElvanDesktopSidebar(
              isCollapsed: isCollapsed,
              onToggleCollapse: () => setState(() => isCollapsed = !isCollapsed),
              currentIndex: widget.currentIndex,
              onTabSelected: widget.onTabSelected,
              navItems: widget.navItems,
              appMode: mode ?? AppMode.gst,
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: CustomScrollView(
                slivers: widget.slivers,
              ),
            ),
          ),
        ],
      ),
    );
  }
}