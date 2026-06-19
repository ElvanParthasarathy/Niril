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
        
        // ── PURE PIXEL POSITION MATH (v2) ──────────────────────────────────
        // Instead of fighting Alignment.lerp against Transform.translate,
        // we measure the text's exact pixel width, compute its centered X
        // and its collapsed-bar target X, then linearly lerp between them.
        // Zero quadratic forces. Zero jitter. Works for ANY text width.

        // MICRO-NUDGES for sub-pixel font-hinting alignment:
        const double xNudge = 1.5; // Horizontal tweak (scaled 34px vs native 20px side-bearings)
        const double yNudge = 0.6; // Vertical tweak (positive = down at handoff)

        final double t = normalizedProgress; // Hits 1.0 at the exact handoff frame

        // 1. Measure the title's intrinsic width at 34px so we can center it mathematically.
        //    We inherit from DefaultTextStyle to pick up the theme's fontFamily,
        //    and apply the MediaQuery textScaler so the measurement matches the render exactly.
        final titleStyle = DefaultTextStyle.of(context).style.copyWith(
          fontSize: 34,
          fontWeight: leadingWidget != null ? FontWeight.w700 : FontWeight.bold,
          letterSpacing: -0.5,
          height: 1.15,
        );
        final textPainter = TextPainter(
          text: TextSpan(text: title, style: titleStyle),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final double textWidth = textPainter.width;
        final double screenWidth = constraints.maxWidth;

        // 2. Compute the two endpoints
        // START (t=0): text visually centered on screen
        final double centeredLeft = (screenWidth - textWidth) / 2;
        // END (t=1): text lands exactly where the collapsed bar's small title sits
        //   Home page:  Positioned(left:16) + Padding(left:8)  = 24px
        //   Subpage:    Positioned(left:16) + Chevron(50) + Gap(12) = 78px
        final double targetLeft = (leadingWidget != null ? 78.0 : 24.0) + xNudge;

        // 3. TWO-PHASE CHOREOGRAPHY:
        //    Phase 1 (t: 0→0.3): Pure vertical lift. Title stays big and centered, just floats up.
        //    Phase 2 (t: 0.3→1.0): Diagonal scale-and-move. Title shrinks and slides to target.
        const double phase1End = 0.3;
        final double phase1T = (t / phase1End).clamp(0.0, 1.0);
        final double phase2T = ((t - phase1End) / (1.0 - phase1End)).clamp(0.0, 1.0);

        // Vertical: phase 1 lifts 20px, phase 2 covers the remaining distance
        const double phase1Lift = 20.0;
        final double totalVertical = 99.0 + yNudge;
        final double currentBottom = 128.0 - (phase1Lift * phase1T) - ((totalVertical - phase1Lift) * phase2T);

        // Scale & horizontal: only during phase 2
        final double currentScale = 1.0 - (1.0 - (20.0 / 34.0)) * phase2T;
        final double currentLeft = centeredLeft + (targetLeft - centeredLeft) * phase2T;

        return Container(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              // ── The Dynamic Scale-and-Move Title ──
              // Positioned at exact pixel coordinates. Transform.scale shrinks
              // the text around its bottom-left anchor so the left edge stays pinned.
              Positioned(
                left: currentLeft,
                bottom: currentBottom,
                child: Opacity(
                  opacity: isPinned ? 0.0 : 1.0, // Hand off to Collapsed Bar when pinned!
                  child: Transform.scale(
                    scale: currentScale,
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      style: titleStyle.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Color.lerp(Colors.white, Colors.white.withOpacity(0.95), t)
                            : Colors.black87,
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