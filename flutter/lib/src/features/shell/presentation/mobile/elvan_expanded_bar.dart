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
        // We are using this as a VISUAL calibration tool (ignoring absolute math) to overcome font side-bearings!
        const double xNudge = 1.5; // Tune this (e.g. 1.0, 2.0) until the ink perfectly overlaps.
        const double yNudge = 0.6; // Up/Down tweak (positive moves scaled text DOWN at handoff)

        // SCALE AND MOVE LOGIC:
        final double t = normalizedProgress; // Use normalizedProgress to finish exactly at handoff!
        
        // CONTINUOUS DIAGONAL CHOREOGRAPHY:
        // No locked phases. The text scales and moves continuously for the entire duration of the scroll.
        // Using a pure linear diagonal (1-to-1 movement) because the user's scrolling thumb
        // is already providing the physical curve. This creates the most connected, tactile feel.
        final double slantT = t;
        
        final double currentScale = 1.0 - (1.0 - (20.0 / 34.0)) * slantT;
        // Native text X offset: 16 (Positioned) + 4 (Padding) + 8 (SizedBox) = 28px
        // Scaled text X offset: 0 (Positioned) + 4 (Padding * scale factor 20/34) + currentLeftPadding
        // Therefore, currentLeftPadding + 2.353 = 28.0 -> currentLeftPadding must be EXACTLY 25.65.
        final double currentLeftPadding = (25.65 + xNudge) * slantT; // 0 to 25.65 ± xNudge
        
        // By using slantT for the vertical bottom anchor, the text's vertical offset completely locks
        // alongside its horizontal offset and scale. This perfectly synchronizes its vertical scrolling speed 
        // with the 3-dot pill during the locked phase!
        final double currentBottom = 128.0 - ((99.0 + yNudge) * slantT); 

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
                
              // ── DEV PIXEL HUD ──
              Positioned(
                top: ceiling + 10,
                right: 16,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                    ),
                    child: Text(
                      't: ${t.toStringAsFixed(6)}\n'
                      'slantT: ${slantT.toStringAsFixed(6)}\n'
                      'Scale: ${currentScale.toStringAsFixed(6)}\n'
                      'LeftPad: ${currentLeftPadding.toStringAsFixed(6)}\n'
                      'AbsX: ${(currentLeftPadding + 4.0 * currentScale).toStringAsFixed(6)}\n'
                      'Bottom: ${currentBottom.toStringAsFixed(6)}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 10,
                        height: 1.5,
                        decoration: TextDecoration.none,
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