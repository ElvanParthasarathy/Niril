import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../localization/locale_provider.dart';
import '../../../../core/models/app_mode.dart';
import '../../../../core/state/app_state.dart';
import '../mobile/elvan_navbar.dart'; // For CustomNavItem
import 'elvan_desktop_sidebar.dart';
import '../../../../core/widgets/elvan_smooth_scroll.dart';

class ElvanDesktopShell extends ConsumerStatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onSettingsPressed;
  final List<CustomNavItem> navItems;
  final List<Widget> slivers; // The pages (SliverOffstage)
  final Widget? customContent;
  final String? title;

  const ElvanDesktopShell({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onSettingsPressed,
    required this.navItems,
    required this.slivers,
    this.customContent,
    this.title,
  });

  @override
  ConsumerState<ElvanDesktopShell> createState() => _ElvanDesktopShellState();
}

class _ElvanDesktopShellState extends ConsumerState<ElvanDesktopShell> {
  bool isCollapsed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
              onSettingsPressed: widget.onSettingsPressed,
              navItems: widget.navItems,
              appMode: mode ?? AppMode.silk,
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: widget.customContent ?? ElvanSmoothScroll(
                controller: _scrollController,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    if (widget.title != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24, left: 36, bottom: 24),
                          child: Text(
                            widget.title!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ...widget.slivers,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}