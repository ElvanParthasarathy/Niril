import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../localization/locale_provider.dart';
import '../../../../core/models/app_mode.dart';
import '../mobile/elvan_navbar.dart'; // For CustomNavItem
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



const String _settingsOutlineSvg = '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M128,80a48,48,0,1,0,48,48A48.05,48.05,0,0,0,128,80Zm0,80a32,32,0,1,1,32-32A32,32,0,0,1,128,160Zm109.94-52.79a8,8,0,0,0-3.89-5.4l-29.83-17-.12-33.62a8,8,0,0,0-2.83-6.08,111.91,111.91,0,0,0-36.72-20.67,8,8,0,0,0-6.46.59L128,41.85,97.88,25a8,8,0,0,0-6.47-.6A112.1,112.1,0,0,0,54.73,45.15a8,8,0,0,0-2.83,6.07l-.15,33.65-29.83,17a8,8,0,0,0-3.89,5.4,106.47,106.47,0,0,0,0,41.56,8,8,0,0,0,3.89,5.4l29.83,17,.12,33.62a8,8,0,0,0,2.83,6.08,111.91,111.91,0,0,0,36.72,20.67,8,8,0,0,0,6.46-.59L128,214.15,158.12,231a7.91,7.91,0,0,0,3.9,1,8.09,8.09,0,0,0,2.57-.42,112.1,112.1,0,0,0,36.68-20.73,8,8,0,0,0,2.83-6.07l.15-33.65,29.83-17a8,8,0,0,0,3.89-5.4A106.47,106.47,0,0,0,237.94,107.21Zm-15,34.91-28.57,16.25a8,8,0,0,0-3,3c-.58,1-1.19,2.06-1.81,3.06a7.94,7.94,0,0,0-1.22,4.21l-.15,32.25a95.89,95.89,0,0,1-25.37,14.3L134,199.13a8,8,0,0,0-3.91-1h-.19c-1.21,0-2.43,0-3.64,0a8.08,8.08,0,0,0-4.1,1l-28.84,16.1A96,96,0,0,1,67.88,201l-.11-32.2a8,8,0,0,0-1.22-4.22c-.62-1-1.23-2-1.8-3.06a8.09,8.09,0,0,0-3-3.06l-28.6-16.29a90.49,90.49,0,0,1,0-28.26L61.67,97.63a8,8,0,0,0,3-3c.58-1,1.19-2.06,1.81-3.06a7.94,7.94,0,0,0,1.22-4.21l.15-32.25a95.89,95.89,0,0,1,25.37-14.3L122,56.87a8,8,0,0,0,4.1,1c1.21,0,2.43,0,3.64,0a8.08,8.08,0,0,0,4.1-1l28.84-16.1A96,96,0,0,1,188.12,55l.11,32.2a8,8,0,0,0,1.22,4.22c.62,1,1.23,2,1.8,3.06a8.09,8.09,0,0,0,3,3.06l28.6,16.29A90.49,90.49,0,0,1,222.9,142.12Z"></path></svg>';
const String _settingsFilledSvg = '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M237.94,107.21a8,8,0,0,0-3.89-5.4l-29.83-17-.12-33.62a8,8,0,0,0-2.83-6.08,111.91,111.91,0,0,0-36.72-20.67,8,8,0,0,0-6.46.59L128,41.85,97.88,25a8,8,0,0,0-6.47-.6A111.92,111.92,0,0,0,54.73,45.15a8,8,0,0,0-2.83,6.07l-.15,33.65-29.83,17a8,8,0,0,0-3.89,5.4,106.47,106.47,0,0,0,0,41.56,8,8,0,0,0,3.89,5.4l29.83,17,.12,33.63a8,8,0,0,0,2.83,6.08,111.91,111.91,0,0,0,36.72,20.67,8,8,0,0,0,6.46-.59L128,214.15,158.12,231a7.91,7.91,0,0,0,3.9,1,8.09,8.09,0,0,0,2.57-.42,112.1,112.1,0,0,0,36.68-20.73,8,8,0,0,0,2.83-6.07l.15-33.65,29.83-17a8,8,0,0,0,3.89-5.4A106.47,106.47,0,0,0,237.94,107.21ZM128,168a40,40,0,1,1,40-40A40,40,0,0,1,128,168Z"></path></svg>';

class _DesktopCollapsedProfile extends ConsumerStatefulWidget {
  final bool isDark;
  
  const _DesktopCollapsedProfile({required this.isDark});

  @override
  ConsumerState<_DesktopCollapsedProfile> createState() => _DesktopCollapsedProfileState();
}

class _DesktopCollapsedProfileState extends ConsumerState<_DesktopCollapsedProfile> {
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
          icon: SvgPicture.string(
            _isHovered ? _settingsFilledSvg : _settingsOutlineSvg,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              _isHovered 
                  ? (widget.isDark ? Colors.white : Colors.black) 
                  : (widget.isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666)),
              BlendMode.srcIn,
            ),
          ),
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