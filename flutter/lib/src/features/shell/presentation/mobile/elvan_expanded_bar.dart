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
        
        // MICRO-NUDGES for Sub-pixel Alignment:
        // A native 20px font and a scaled 34px font have slightly different internal baselines and kerning (font hinting).
        // We apply a fractional pixel offset to the final scaled position to perfectly eclipse the native text.
        // Tune these numbers (e.g. 0.2, -0.5, 1.0) until the "shake" completely disappears to your eye!
        const double xNudge = 0.8; // Left/Right tweak (positive moves scaled text RIGHT at handoff)
        const double yNudge = 0.6; // Up/Down tweak (positive moves scaled text DOWN at handoff)

        // SCALE AND MOVE LOGIC:
        final double t = normalizedProgress; // Use normalizedProgress to finish exactly at handoff!
        
        // 1. "Not on start itself": We start slanting immediately at t=0 (expanded).
        // 2. "Smooth curve": We use easeOutCubic to smoothly decelerate the slanting.
        // 3. "Pure vertical then": We finish the slant early at 85%, leaving the last 15% as a pure vertical line.
        const double detachThreshold = 0.85;
        final double rawSlant = (t / detachThreshold).clamp(0.0, 1.0);
        final double slantT = Curves.easeOutCubic.transform(rawSlant);
        
        final double linearScale = 1.0 - (1.0 - (20.0 / 34.0)) * t;
        final double currentScale = 1.0 - (1.0 - (20.0 / 34.0)) * slantT;
        final double currentLeftPadding = (28.0 + xNudge) * slantT; // 0 to 28 ± xNudge
        
        // MATHEMATICAL ANCHOR CORRECTION:
        // Because the text shrinks early, its visual center of mass would drift and look "broken".
        // We calculate the exact pixel difference and counteract it, keeping the text flawlessly glued!
        // (34px font * 1.2 height + 24px padding) / 2 = 32.4px half-height.
        final double centerCorrection = 32.4 * (currentScale - linearScale);
        final double currentBottom = 128.0 - ((99.0 + yNudge) * t) - centerCorrection;

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
                        : Alignment.lerp(Alignment.bottomCenter, Alignment.bottomLeft, slantT)!,
                    child: Padding(
                      padding: EdgeInsets.only(left: leadingWidget != null ? 0 : currentLeftPadding),
                      child: Transform.scale(
                        scale: leadingWidget != null ? 1.0 : currentScale,
                        alignment: leadingWidget != null
                            ? Alignment.bottomCenter
                            : Alignment.lerp(Alignment.bottomCenter, Alignment.bottomLeft, t)!,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: leadingWidget != null ? FontWeight.w700 : FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Color.lerp(Colors.white, Colors.white.withOpacity(0.95), t)
                                : Colors.black87,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
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