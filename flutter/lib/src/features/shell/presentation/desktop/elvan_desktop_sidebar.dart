import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../localization/locale_provider.dart';
import '../mobile/widgets/elvan_page_route.dart';
import '../../../niril_common/presentation/widgets/elvan_settings_icon.dart';
import '../../../../core/models/app_mode.dart';
import '../../../../core/state/app_state.dart';
import '../mobile/elvan_navbar.dart'; // For CustomNavItem
import '../../../../core/utils/app_svgs.dart';
import '../../../auth/presentation/mode_selector_screen.dart';
import '../../../settings/presentation/settings_screen.dart';

const String _sidebarCollapseSvg = '''
<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.25" stroke-linecap="round" stroke-linejoin="round">
  <path d="M10 6L5 9L10 12" />
  <path d="M14 6H19" />
  <path d="M14 12H19" />
  <path d="M5 18H19" />
</svg>
''';

const String _settingsOutlineSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M128,80a48,48,0,1,0,48,48A48.05,48.05,0,0,0,128,80Zm0,80a32,32,0,1,1,32-32A32,32,0,0,1,128,160Zm109.94-52.79a8,8,0,0,0-3.89-5.4l-29.83-17-.12-33.62a8,8,0,0,0-2.83-6.08,111.91,111.91,0,0,0-36.72-20.67,8,8,0,0,0-6.46.59L128,41.85,97.88,25a8,8,0,0,0-6.47-.6A112.1,112.1,0,0,0,54.73,45.15a8,8,0,0,0-2.83,6.07l-.15,33.65-29.83,17a8,8,0,0,0-3.89,5.4,106.47,106.47,0,0,0,0,41.56,8,8,0,0,0,3.89,5.4l29.83,17,.12,33.62a8,8,0,0,0,2.83,6.08,111.91,111.91,0,0,0,36.72,20.67,8,8,0,0,0,6.46-.59L128,214.15,158.12,231a7.91,7.91,0,0,0,3.9,1,8.09,8.09,0,0,0,2.57-.42,112.1,112.1,0,0,0,36.68-20.73,8,8,0,0,0,2.83-6.07l.15-33.65,29.83-17a8,8,0,0,0,3.89-5.4A106.47,106.47,0,0,0,237.94,107.21Zm-15,34.91-28.57,16.25a8,8,0,0,0-3,3c-.58,1-1.19,2.06-1.81,3.06a7.94,7.94,0,0,0-1.22,4.21l-.15,32.25a95.89,95.89,0,0,1-25.37,14.3L134,199.13a8,8,0,0,0-3.91-1h-.19c-1.21,0-2.43,0-3.64,0a8.08,8.08,0,0,0-4.1,1l-28.84,16.1A96,96,0,0,1,67.88,201l-.11-32.2a8,8,0,0,0-1.22-4.22c-.62-1-1.23-2-1.8-3.06a8.09,8.09,0,0,0-3-3.06l-28.6-16.29a90.49,90.49,0,0,1,0-28.26L61.67,97.63a8,8,0,0,0,3-3c.58-1,1.19-2.06,1.81-3.06a7.94,7.94,0,0,0,1.22-4.21l.15-32.25a95.89,95.89,0,0,1,25.37-14.3L122,56.87a8,8,0,0,0,4.1,1c1.21,0,2.43,0,3.64,0a8.08,8.08,0,0,0,4.1-1l28.84-16.1A96,96,0,0,1,188.12,55l.11,32.2a8,8,0,0,0,1.22,4.22c.62,1,1.23,2,1.8,3.06a8.09,8.09,0,0,0,3,3.06l28.6,16.29A90.49,90.49,0,0,1,222.9,142.12Z"></path></svg>';
const String _settingsFilledSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="#000000" viewBox="0 0 256 256"><path d="M237.94,107.21a8,8,0,0,0-3.89-5.4l-29.83-17-.12-33.62a8,8,0,0,0-2.83-6.08,111.91,111.91,0,0,0-36.72-20.67,8,8,0,0,0-6.46.59L128,41.85,97.88,25a8,8,0,0,0-6.47-.6A111.92,111.92,0,0,0,54.73,45.15a8,8,0,0,0-2.83,6.07l-.15,33.65-29.83,17a8,8,0,0,0-3.89,5.4,106.47,106.47,0,0,0,0,41.56,8,8,0,0,0,3.89,5.4l29.83,17,.12,33.63a8,8,0,0,0,2.83,6.08,111.91,111.91,0,0,0,36.72,20.67,8,8,0,0,0,6.46-.59L128,214.15,158.12,231a7.91,7.91,0,0,0,3.9,1,8.09,8.09,0,0,0,2.57-.42,112.1,112.1,0,0,0,36.68-20.73,8,8,0,0,0,2.83-6.07l.15-33.65,29.83-17a8,8,0,0,0,3.89-5.4A106.47,106.47,0,0,0,237.94,107.21ZM128,168a40,40,0,1,1,40-40A40,40,0,0,1,128,168Z"></path></svg>';

class ElvanDesktopSidebar extends ConsumerWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onSettingsPressed;
  final List<CustomNavItem> navItems;
  final AppMode appMode;

  const ElvanDesktopSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onSettingsPressed,
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
                  child: _DesktopNavItem(
                    item: item,
                    isSelected: isSelected,
                    isDark: isDark,
                    isCollapsed: isCollapsed,
                    onTap: () => onTabSelected(index),
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
              crossFadeState: isCollapsed
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
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

  Widget _buildHeaderCrossFade(
      BuildContext context, WidgetRef ref, bool isDark) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      firstCurve: const Cubic(0.2, 0.0, 0.0, 1.0),
      secondCurve: const Cubic(0.2, 0.0, 0.0, 1.0),
      alignment: Alignment.centerLeft,
      crossFadeState:
          isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: Container(
        width: 260,
        height: 80,
        padding: const EdgeInsets.only(top: 32, bottom: 8, left: 32, right: 24),
        alignment: Alignment.topLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'appName'.tr(context, ref),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.0,
              ),
            ),
            IconButton(
              icon: SvgPicture.string(
                _sidebarCollapseSvg,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
              ),
              onPressed: onToggleCollapse,
              splashRadius: 20,
              hoverColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
            ),
          ],
        ),
      ),
      secondChild: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.only(top: 32, bottom: 8),
        alignment: Alignment.topCenter,
        child: IconButton(
          icon: Transform.scale(
            scaleX: -1,
            child: SvgPicture.string(
              _sidebarCollapseSvg,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
            ),
          ),
          onPressed: onToggleCollapse,
          splashRadius: 20,
          hoverColor: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
    );
  }

  Widget _buildCollapsedProfile(BuildContext context, bool isDark) {
    return _DesktopCollapsedProfile(
        isDark: isDark, onSettingsPressed: onSettingsPressed);
  }

  Widget _buildExpandedProfile(
      BuildContext context, bool isDark, WidgetRef ref) {
    return _DesktopExpandedProfile(
        isDark: isDark, appMode: appMode, onSettingsPressed: onSettingsPressed);
  }
}

class _DesktopNavItem extends StatefulWidget {
  final CustomNavItem item;
  final bool isSelected;
  final bool isDark;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _DesktopNavItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_DesktopNavItem> createState() => _DesktopNavItemState();
}

class _DesktopNavItemState extends State<_DesktopNavItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final expandedBgColor = widget.isSelected
        ? (widget.isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.06))
        : (_isHovered
            ? (widget.isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.04))
            : Colors.transparent);

    final collapsedBgColor = widget.isSelected
        ? (widget.isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.06))
        : (_isHovered
            ? (widget.isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.04))
            : Colors.transparent);

    final fgColor = widget.isSelected || _isHovered
        ? (widget.isDark ? Colors.white : Colors.black)
        : (widget.isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666));

    final expandedSplash = widget.isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.12);
    final expandedHighlight = widget.isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.black.withOpacity(0.04);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.2, 0.0, 0.0, 1.0),
        width: widget.isCollapsed ? 56 : 236,
        height: widget.isCollapsed ? 78 : 40,
        child: Stack(
          children: [
            // Expanded Pill Background
            IgnorePointer(
              ignoring: widget.isCollapsed,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: widget.isCollapsed ? 0.0 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: const Cubic(0.2, 0.0, 0.0, 1.0),
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: expandedBgColor,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: widget.isCollapsed ? null : widget.onTap,
                      onTapDown: widget.isCollapsed
                          ? null
                          : (_) => setState(() => _isPressed = true),
                      onTapCancel: widget.isCollapsed
                          ? null
                          : () => setState(() => _isPressed = false),
                      onHighlightChanged: widget.isCollapsed
                          ? null
                          : (h) {
                              if (!h) setState(() => _isPressed = false);
                            },
                      hoverColor: expandedHighlight,
                      splashColor: expandedSplash,
                      highlightColor: expandedHighlight,
                    ),
                  ),
                ),
              ),
            ),

            // Collapsed Pill Background
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: const Cubic(0.2, 0.0, 0.0, 1.0),
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                ignoring: !widget.isCollapsed,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: widget.isCollapsed ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: const Cubic(0.2, 0.0, 0.0, 1.0),
                      width: 56,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: collapsedBgColor,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: widget.isCollapsed ? widget.onTap : null,
                          onTapDown: widget.isCollapsed
                              ? (_) => setState(() => _isPressed = true)
                              : null,
                          onTapCancel: widget.isCollapsed
                              ? () => setState(() => _isPressed = false)
                              : null,
                          onHighlightChanged: widget.isCollapsed
                              ? (h) {
                                  if (!h) setState(() => _isPressed = false);
                                }
                              : null,
                          hoverColor: Colors.transparent,
                          splashColor: expandedSplash,
                          highlightColor: expandedHighlight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Expanded Text
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: const Cubic(0.2, 0.0, 0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 48),
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: widget.isCollapsed ? 0.0 : 1.0,
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: fgColor,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
            ),

            // Collapsed Text
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: const Cubic(0.2, 0.0, 0.0, 1.0),
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: widget.isCollapsed ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(height: 14, width: 56),
                        Positioned(
                          left: -10,
                          width: 76,
                          child: Text(
                            widget.item.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'ElvanSans',
                              fontSize: 10.5,
                              fontWeight: widget.isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: fgColor,
                              height: 1.2,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // The Flying Icon
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: const Cubic(0.2, 0.0, 0.0, 1.0),
              alignment: widget.isCollapsed
                  ? Alignment.topCenter
                  : Alignment.centerLeft,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                curve: const Cubic(0.2, 0.0, 0.0, 1.0),
                padding: EdgeInsets.only(
                  left: widget.isCollapsed ? 0 : 18,
                  top: widget.isCollapsed ? 16 : 0,
                ),
                child: IgnorePointer(
                  child: AnimatedScale(
                    scale: _isPressed ? 0.85 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    curve: const Cubic(0.4, 0.0, 0.2, 1.0),
                    child:
                        _buildIcon(fgColor, widget.isCollapsed ? 24.0 : 20.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, double size) {
    if (widget.item.svgString != null) {
      return SvgPicture.string(
        widget.isSelected && widget.item.activeSvgString != null
            ? widget.item.activeSvgString!
            : widget.item.svgString!,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else {
      return Icon(
        widget.isSelected && widget.item.activeIcon != null
            ? widget.item.activeIcon
            : widget.item.icon,
        size: size,
        color: color,
      );
    }
  }
}

class _DesktopCollapsedProfile extends ConsumerStatefulWidget {
  final bool isDark;
  final VoidCallback onSettingsPressed;
  final bool isSettingsActive;

  const _DesktopCollapsedProfile({
    required this.isDark,
    required this.onSettingsPressed,
    this.isSettingsActive = false,
  });

  @override
  ConsumerState<_DesktopCollapsedProfile> createState() =>
      _DesktopCollapsedProfileState();
}

class _DesktopCollapsedProfileState
    extends ConsumerState<_DesktopCollapsedProfile> {
  bool _isSettingsHovered = false;

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
        onEnter: (_) => setState(() => _isSettingsHovered = true),
        onExit: (_) => setState(() => _isSettingsHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onSettingsPressed,
            hoverColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            splashColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: SvgPicture.string(
                  _isSettingsHovered ? _settingsFilledSvg : _settingsOutlineSvg,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    _isSettingsHovered
                        ? (widget.isDark ? Colors.white : Colors.black)
                        : (widget.isDark
                            ? const Color(0xFFAAAAAA)
                            : const Color(0xFF666666)),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopExpandedProfile extends ConsumerStatefulWidget {
  final bool isDark;
  final AppMode appMode;
  final VoidCallback onSettingsPressed;

  const _DesktopExpandedProfile(
      {required this.isDark,
      required this.appMode,
      required this.onSettingsPressed});

  @override
  ConsumerState<_DesktopExpandedProfile> createState() =>
      _DesktopExpandedProfileState();
}

class _DesktopExpandedProfileState
    extends ConsumerState<_DesktopExpandedProfile> {
  bool _isModeHovered = false;
  bool _isSettingsHovered = false;

  @override
  Widget build(BuildContext context) {
    final modeFgColor = _isModeHovered
        ? (widget.isDark ? Colors.white : Colors.black)
        : (widget.isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _isModeHovered = true),
            onExit: (_) => setState(() => _isModeHovered = false),
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ModeSelectorScreen(
                        onModeSelected: (mode) {
                          ref.read(appModeProvider.notifier).setMode(mode);
                          Navigator.of(context).pop();
                        },
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      fullscreenDialog: true,
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                hoverColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
                splashColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.12),
                highlightColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.string(
                        widget.appMode == AppMode.coolie
                            ? AppSvgs.coolieMode
                            : AppSvgs.silkMode,
                        width: 16,
                        height: 16,
                        colorFilter:
                            ColorFilter.mode(modeFgColor, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: modeFgColor,
                            fontFamily:
                                DefaultTextStyle.of(context).style.fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: Text(
                            widget.appMode == AppMode.coolie
                                ? 'nirilCoolie'.tr(context, ref)
                                : 'nirilSilk'.tr(context, ref),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        MouseRegion(
          onEnter: (_) => setState(() => _isSettingsHovered = true),
          onExit: (_) => setState(() => _isSettingsHovered = false),
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onSettingsPressed,
              hoverColor: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              splashColor: widget.isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.12),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                alignment: Alignment.center,
                child: SvgPicture.string(
                  _isSettingsHovered ? _settingsFilledSvg : _settingsOutlineSvg,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    _isSettingsHovered
                        ? (widget.isDark ? Colors.white : Colors.black)
                        : (widget.isDark
                            ? const Color(0xFFAAAAAA)
                            : const Color(0xFF666666)),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
