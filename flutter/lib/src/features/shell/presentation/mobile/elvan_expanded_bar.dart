import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDED BAR DELEGATE (Massive Title Header)
// ─────────────────────────────────────────────────────────────────────────────

class ElvanExpandedBarDelegate extends SliverPersistentHeaderDelegate {
  ElvanExpandedBarDelegate({
    required this.title,
    required this.navActions,
    required this.statusBarHeight,
    required this.expandedHeight,
    this.leadingWidget,
    required this.isSearchActiveNotifier,
    required this.isMenuOpen,
  });

  final String title;
  final List<Widget> navActions;
  final double statusBarHeight;
  final double expandedHeight;
  final Widget? leadingWidget;
  final ValueNotifier<bool> isSearchActiveNotifier;
  final bool isMenuOpen;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => statusBarHeight + 72.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ValueListenableBuilder<bool>(
      valueListenable: isSearchActiveNotifier,
      builder: (context, isSearchActive, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
        final double currentHeight = constraints.maxHeight;
        final double maxShrink = maxExtent - minExtent;
        final double shrinkProgress = (shrinkOffset / maxShrink).clamp(0.0, 1.0);
        final double titleOpacity = (1.0 - (shrinkProgress * 1.5)).clamp(0.0, 1.0);

        final double expandedButtonsBottom = 8.0;
        double currentTop = currentHeight - expandedButtonsBottom - kToolbarHeight;
        final double ceiling = statusBarHeight + 20.0;
        
        bool isPinned = currentTop <= ceiling;
        if (isPinned) {
           currentTop = ceiling;
        }

        // Calculate the exact mathematical progress where the handoff triggers
        final double handoffHeight = ceiling + expandedButtonsBottom + kToolbarHeight;
        final double handoffShrinkOffset = maxExtent - handoffHeight;
        final double handoffProgress = (handoffShrinkOffset / maxShrink).clamp(0.001, 1.0);
        
        // This progress hits exactly 1.0 at the precise millisecond of the hand-off.
        final double normalizedProgress = (shrinkProgress / handoffProgress).clamp(0.0, 1.0);
        
        // SCALE AND MOVE LOGIC:
        final double t = normalizedProgress; // Use normalizedProgress to finish exactly at handoff!
        final double currentBottom = 128.0 - (99.0 * t); // 128 down to 29 (fixes the Y-axis jump!)
        final double currentLeftPadding = 28.0 * t; // 0 to 28
        final double currentFontSize = 34.0 - (14.0 * t); // 34 to 20
        final double currentLetterSpacing = -0.5 + (0.2 * t); // -0.5 to -0.3

        return Container(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              // ── The Dynamic Scale-and-Move Title ──
              // If there's a leading widget (subpage), we fade out the big title.
              // Otherwise, we physically move and shrink it into the small title!
              Positioned(
                left: 0,
                right: 0,
                bottom: leadingWidget != null ? 128.0 : currentBottom, 
                child: Opacity(
                  opacity: leadingWidget != null 
                      ? titleOpacity 
                      : (isPinned ? 0.0 : 1.0), // Hand off to Collapsed Bar when pinned!
                  child: Align(
                    alignment: leadingWidget != null 
                        ? Alignment.bottomCenter 
                        : Alignment.lerp(Alignment.bottomCenter, Alignment.bottomLeft, t)!,
                    child: Padding(
                      padding: EdgeInsets.only(left: leadingWidget != null ? 0 : currentLeftPadding),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: leadingWidget != null ? 34 : currentFontSize,
                          fontWeight: leadingWidget != null ? FontWeight.w700 : FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Color.lerp(Colors.white, Colors.white.withOpacity(0.95), t)
                              : Colors.black87,
                          letterSpacing: leadingWidget != null ? -0.5 : currentLetterSpacing,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── The Page Header Leading Icon (Left) ──
              if (leadingWidget != null)
                Positioned(
                  top: currentTop,
                  left: 16,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Opacity(
                      opacity: isPinned ? 0.0 : 1.0, // Hand off to Collapsed Bar when pinned!
                      child: leadingWidget,
                    ),
                  ),
                ),
              // ── The Page Header Icons (Right) ──
              if (navActions.isNotEmpty)
                Positioned(
                  top: currentTop,
                  right: 16,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: (isSearchActive || isMenuOpen) ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: isSearchActive || isMenuOpen,
                        child: Opacity(
                          opacity: isPinned ? 0.0 : 1.0, // Hand off to Collapsed Bar when pinned!
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: navActions,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
    );
  }

  @override
  bool shouldRebuild(covariant ElvanExpandedBarDelegate oldDelegate) {
    return title != oldDelegate.title ||
        navActions != oldDelegate.navActions ||
        expandedHeight != oldDelegate.expandedHeight ||
        leadingWidget != oldDelegate.leadingWidget ||
        isSearchActiveNotifier != oldDelegate.isSearchActiveNotifier ||
        isMenuOpen != oldDelegate.isMenuOpen;
  }
}