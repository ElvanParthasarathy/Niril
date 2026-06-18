import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../localization/locale_provider.dart';
import '../../../../core/models/app_mode.dart';
import '../mobile/elvan_navbar.dart'; // For CustomNavItem
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../../../settings/presentation/settings_screen.dart';

class ElvanDesktopSidebar extends ConsumerWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<CustomNavItem> navItems;
  final AppMode appMode;

  const ElvanDesktopSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.currentIndex,
    required this.onTabSelected,
    required this.navItems,
    required this.appMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (App Name + Toggle)
          _buildHeaderCrossFade(context, ref, isDark),

          // Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = index == currentIndex;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: isCollapsed ? 12 : 10),
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    firstCurve: const Cubic(0.2, 0.0, 0.0, 1.0),
                    secondCurve: const Cubic(0.2, 0.0, 0.0, 1.0),
                    alignment: Alignment.centerLeft,
                    crossFadeState: isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: SizedBox(
                      width: 236, // 260 - 24 padding
                      child: _buildExpandedItem(item, index, isSelected, isDark),
                    ),
                    secondChild: SizedBox(
                      width: 56, // 80 - 24 padding
                      child: _buildCollapsedItem(item, index, isSelected, isDark),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Settings / Profile Zone
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstCurve: const Cubic(0.2, 0.0, 0.0, 1.0),
              secondCurve: const Cubic(0.2, 0.0, 0.0, 1.0),
              alignment: Alignment.centerLeft,
              crossFadeState: isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: SizedBox(
                width: 236, // 260 - 24 padding
                child: _buildExpandedProfile(context, isDark, ref),
              ),
              secondChild: SizedBox(
                width: 56,
                child: _buildCollapsedProfile(context, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCrossFade(BuildContext context, WidgetRef ref, bool isDark) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      firstCurve: const Cubic(0.2, 0.0, 0.0, 1.0),
      secondCurve: const Cubic(0.2, 0.0, 0.0, 1.0),
      alignment: Alignment.centerLeft,
      crossFadeState: isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: Container(
        width: 260,
        height: 80,
        padding: const EdgeInsets.only(top: 24, bottom: 8, left: 32, right: 24),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'appName'.tr(context, ref),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: Theme.of(context).colorScheme.primary,
                height: 1.0,
              ),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.chevron_left),
              color: Theme.of(context).colorScheme.primary,
              onPressed: onToggleCollapse,
              splashRadius: 20,
              hoverColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
            ),
          ],
        ),
      ),
      secondChild: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        alignment: Alignment.center,
        child: IconButton(
          icon: const Icon(CupertinoIcons.chevron_right),
          color: Theme.of(context).colorScheme.primary,
          onPressed: onToggleCollapse,
          splashRadius: 20,
          hoverColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
        ),
      ),
    );
  }

  Widget _buildExpandedItem(CustomNavItem item, int index, bool isSelected, bool isDark) {
    return _DesktopExpandedNavItem(
      item: item,
      isSelected: isSelected,
      isDark: isDark,
      onTap: () => onTabSelected(index),
    );
  }

  Widget _buildCollapsedItem(CustomNavItem item, int index, bool isSelected, bool isDark) {
    return _DesktopCollapsedNavItem(
      item: item,
      isSelected: isSelected,
      isDark: isDark,
      onTap: () => onTabSelected(index),
    );
  }

  Widget _buildCollapsedProfile(BuildContext context, bool isDark) {
    return _DesktopCollapsedProfile(isDark: isDark);
  }

  Widget _buildExpandedProfile(BuildContext context, bool isDark, WidgetRef ref) {
    return _DesktopExpandedProfile(isDark: isDark, appMode: appMode);
  }
}

class _DesktopExpandedNavItem extends StatefulWidget {
  final CustomNavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _DesktopExpandedNavItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_DesktopExpandedNavItem> createState() => _DesktopExpandedNavItemState();
}

class _DesktopExpandedNavItemState extends State<_DesktopExpandedNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSelected
        ? (widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06))
        : (_isHovered
            ? (widget.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04))
            : Colors.transparent);

    final fgColor = widget.isSelected || _isHovered
        ? (widget.isDark ? Colors.white : Colors.black)
        : (widget.isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: const Cubic(0.2, 0.0, 0.0, 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: bgColor,
          ),
          child: Row(
            children: [
              _buildIcon(fgColor, 20.0),
              const SizedBox(width: 10),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: fgColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, double size) {
    if (widget.item.svgString != null) {
      return SvgPicture.string(
        widget.isSelected && widget.item.activeSvgString != null ? widget.item.activeSvgString! : widget.item.svgString!,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else {
      return Icon(
        widget.isSelected && widget.item.activeIcon != null ? widget.item.activeIcon : widget.item.icon,
        size: size,
        color: color,
      );
    }
  }
}

class _DesktopCollapsedNavItem extends StatefulWidget {
  final CustomNavItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _DesktopCollapsedNavItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_DesktopCollapsedNavItem> createState() => _DesktopCollapsedNavItemState();
}

class _DesktopCollapsedNavItemState extends State<_DesktopCollapsedNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final pillBgColor = widget.isSelected
        ? (widget.isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06))
        : (_isHovered
            ? (widget.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04))
            : Colors.transparent);

    final fgColor = widget.isSelected || _isHovered
        ? (widget.isDark ? Colors.white : Colors.black)
        : (widget.isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: const Cubic(0.2, 0.0, 0.0, 1.0),
                width: 56,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: pillBgColor,
                ),
                alignment: Alignment.center,
                child: _buildIcon(fgColor, 24.0),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: const Cubic(0.2, 0.0, 0.0, 1.0),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: fgColor,
                  height: 1.2,
                  letterSpacing: 0.2,
                  fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                ),
                child: Text(widget.item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, double size) {
    if (widget.item.svgString != null) {
      return SvgPicture.string(
        widget.isSelected && widget.item.activeSvgString != null ? widget.item.activeSvgString! : widget.item.svgString!,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else {
      return Icon(
        widget.isSelected && widget.item.activeIcon != null ? widget.item.activeIcon : widget.item.icon,
        size: size,
        color: color,
      );
    }
  }
}

class _DesktopCollapsedProfile extends StatefulWidget {
  final bool isDark;
  
  const _DesktopCollapsedProfile({required this.isDark});

  @override
  State<_DesktopCollapsedProfile> createState() => _DesktopCollapsedProfileState();
}

class _DesktopCollapsedProfileState extends State<_DesktopCollapsedProfile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: IconButton(
          icon: const Icon(CupertinoIcons.settings),
          color: _isHovered 
              ? (widget.isDark ? Colors.white : Colors.black) 
              : (widget.isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666)),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          hoverColor: widget.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
        ),
      ),
    );
  }
}

class _DesktopExpandedProfile extends ConsumerStatefulWidget {
  final bool isDark;
  final AppMode appMode;

  const _DesktopExpandedProfile({required this.isDark, required this.appMode});

  @override
  ConsumerState<_DesktopExpandedProfile> createState() => _DesktopExpandedProfileState();
}

class _DesktopExpandedProfileState extends ConsumerState<_DesktopExpandedProfile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final fgColor = _isHovered 
        ? (widget.isDark ? Colors.white : Colors.black) 
        : (widget.isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.appMode == AppMode.coolie ? CupertinoIcons.money_dollar_circle_fill : CupertinoIcons.doc_text_fill,
                  size: 16,
                  color: fgColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: fgColor,
                    fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Text(
                    widget.appMode == AppMode.coolie ? 'nirilCoolie'.tr(context, ref) : 'nirilSilk'.tr(context, ref),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.settings, size: 18),
                color: widget.isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                hoverColor: widget.isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08),
              ),
            ],
          ),
        ),
      ),
    );
  }
}