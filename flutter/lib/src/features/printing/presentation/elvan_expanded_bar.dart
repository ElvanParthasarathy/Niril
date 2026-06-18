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
  });

  final String title;
  final List<Widget> navActions;
  final double statusBarHeight;

  @override
  double get maxExtent => 320.0;

  @override
  double get minExtent => statusBarHeight + 72.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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

        return Container(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              // ── Massive Title ──
              Positioned(
                left: 24,
                right: 24,
                bottom: 64 + expandedButtonsBottom + kToolbarHeight, 
                child: Opacity(
                  opacity: titleOpacity,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
              // ── The Page Header Icons (Right) ──
              Positioned(
                top: currentTop,
                right: 16,
                child: Align(
                  alignment: Alignment.centerRight,
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
              // ── The Back Button (Left) ──
              if (Navigator.canPop(context))
                Positioned(
                  top: currentTop,
                  left: 16,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Opacity(
                      opacity: isPinned ? 0.0 : 1.0, // Hand off to Collapsed Bar when pinned!
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        child: IconButton(
                          icon: const Icon(CupertinoIcons.back),
                          onPressed: () => Navigator.pop(context),
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: EdgeInsets.zero,
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

  @override
  bool shouldRebuild(covariant ElvanExpandedBarDelegate oldDelegate) {
    return title != oldDelegate.title ||
        navActions != oldDelegate.navActions ||
        statusBarHeight != oldDelegate.statusBarHeight;
  }
}
