import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'elvan_popup_menu.dart';

class ElvanCustomAppBarDelegate extends SliverPersistentHeaderDelegate {
  ElvanCustomAppBarDelegate({
    required this.title,
    this.navActions = const [],
    this.expandedHeight = 320.0,
    this.leadingWidget,
    required this.statusBarHeight,
    required this.isMenuOpen,
  });

  final String title;
  final List<Widget> navActions;
  final Widget? leadingWidget;
  final double expandedHeight;
  final double statusBarHeight;
  final bool isMenuOpen;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => statusBarHeight + 100.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // If the scroll view allows overscroll bouncing at the top, shrinkOffset can be negative.
    // If we want stretch: true behavior, we can handle negative shrinkOffset to expand the background.
    final double boundedShrinkOffset = math.max(0.0, shrinkOffset);
    final double maxShrink = maxExtent - minExtent;
    final double shrinkProgress =
        (boundedShrinkOffset / maxShrink).clamp(0.0, 1.0);

    final double screenWidth = MediaQuery.of(context).size.width;

    // The animation matches the exact scroll offset from 0 to 1
    final double t = shrinkProgress;

    // 1. Calculate positions
    final double expandedButtonsBottom = 8.0;
    final double ceiling = statusBarHeight + 20.0;
    final double expandedTop =
        maxExtent - expandedButtonsBottom - kToolbarHeight;

    // Instead of raw pixels, we map the 3-dots pill journey to the overall animation percentage (t).
    // This guarantees the pill always reaches exactly `ceiling` (Status Bar + 20) the millisecond the header finishes collapsing.
    final double currentTop = expandedTop - (expandedTop - ceiling) * t;

    // 2. Measure title for math
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
    final double centeredLeft = math.max(16.0, (screenWidth - textWidth) / 2);
    final double targetLeft =
        (leadingWidget != null ? 78.0 : 24.0) + 1.5; // +xNudge

    final double currentLeft = centeredLeft + (targetLeft - centeredLeft) * t;
    final double currentScale = 1.0 - (1.0 - (20.0 / 34.0)) * t;

    // We position the title relative to the bottom so it shrinks naturally
    // At t=0, it's roughly expandedHeight - 128 from bottom.
    // At t=1, the boundary is 28px lower, so we need it at 40.5 from bottom to perfectly align with the 56px icons pill.
    final double currentBottom = 128.0 - (87.5 * t);

    // 3. Frosted Glass Background (Smooth Fade-in Collision Math)
    const double contentPaddingTop = 12.0;
    final double pillAbsoluteBottom = ceiling + 56.0;
    final double collisionOffset =
        maxExtent + contentPaddingTop - pillAbsoluteBottom;
    final double liftStartOffset = collisionOffset - 12.0;

    double liftProgress = 0.0;
    if (shrinkOffset > liftStartOffset) {
      liftProgress = ((shrinkOffset - liftStartOffset) / 12.0).clamp(0.0, 1.0);
    }

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: Colors.yellow.withValues(alpha: 0.3), // TEMPORARY DEBUG YELLOW
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          // ── The Top Gradient Fade Mask ──
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 96.0,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor, // Solid at the very top edge
                      backgroundColor.withAlpha(140),
                      backgroundColor.withAlpha(40),
                      backgroundColor.withAlpha(0), // Fully transparent below
                    ],
                    stops: const [0.0, 0.35, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── The Dynamic Scale-and-Move Title ──
          Positioned(
            left: currentLeft,
            bottom: currentBottom,
            child: IgnorePointer(
              ignoring:
                  true, // Title shouldn't block touches to the cards below
              child: Transform.scale(
                scale: currentScale,
                alignment: Alignment.bottomLeft,
                child: Opacity(
                  opacity: 1.0 - liftProgress,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: math.max(0.0,
                          (screenWidth - currentLeft - 16.0) / currentScale),
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Color.lerp(Colors.white,
                                Colors.white.withValues(alpha: 0.95), t)
                            : Colors.black87,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: liftProgress > 0
                        ? [
                            BoxShadow(
                              blurRadius: 16 * liftProgress,
                              offset: Offset(0, 4 * liftProgress),
                              color: Colors.black
                                  .withValues(alpha: 0.05 * liftProgress),
                            )
                          ]
                        : null,
                  ),
                  child: Material(
                    type: MaterialType.canvas,
                    color: liftProgress > 0
                        ? (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white)
                            .withValues(alpha: 0.88 * liftProgress)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    clipBehavior: Clip.antiAlias,
                    child: leadingWidget!,
                  ),
                ),
              ),
            ),

          // ── The App Bar Icons (Stretches with header, fades out upon collision) ──
          if (navActions.isNotEmpty)
            Positioned(
              top: currentTop,
              right: 16,
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isMenuOpen
                      ? 0.0
                      : (1.0 - liftProgress), // FADES OUT AS PILL FADES IN
                  child: IgnorePointer(
                    ignoring: isMenuOpen ||
                        liftProgress > 0, // Disable touches once handed off
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: navActions,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ElvanCustomAppBarDelegate oldDelegate) {
    return title != oldDelegate.title ||
        navActions != oldDelegate.navActions ||
        expandedHeight != oldDelegate.expandedHeight ||
        leadingWidget != oldDelegate.leadingWidget ||
        isMenuOpen != oldDelegate.isMenuOpen;
  }
}
