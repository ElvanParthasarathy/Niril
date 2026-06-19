import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../elvan_navbar.dart';

class ElvanPillShifter extends StatefulWidget {
  const ElvanPillShifter({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onValueChanged,
  });

  final List<CustomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onValueChanged;

  @override
  State<ElvanPillShifter> createState() => _ElvanPillShifterState();
}

class _ElvanPillShifterState extends State<ElvanPillShifter> {
  bool _isInteracting = false;
  double? _dragOffset;
  double _touchOffsetFromCenter = 0.0;
  int? _hoverIndex;
  int? _localLockedIndex;

  @override
  void didUpdateWidget(covariant ElvanPillShifter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _localLockedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final int itemCount = widget.items.length;
    final double layoutWidth = 140.0; // Wider to fit icon + long text like 'பற்றுச்சீட்டுகள்'
    final double bgWidth = 148.0;     // Slightly larger than layoutWidth for overlap
    
    const double horizontalPadding = 10.0; // 4px inner overlap + 6px gap = 10px total padding
    const double verticalPadding = 6.0; // Tweaked for 50px total height

    int activeVisualIndex = (_isInteracting && _hoverIndex != null) 
        ? _hoverIndex! 
        : (_localLockedIndex ?? widget.currentIndex);

    double targetLeft;
    if (_isInteracting && _dragOffset != null) {
      targetLeft = _dragOffset! - (bgWidth / 2);
    } else {
      double overlap = (bgWidth - layoutWidth) / 2;
      targetLeft = (activeVisualIndex * layoutWidth) - overlap;
    }

    double maxLeft = ((itemCount - 1) * layoutWidth) - ((bgWidth - layoutWidth) / 2);
    double minLeft = -((bgWidth - layoutWidth) / 2);
    targetLeft = targetLeft.clamp(minLeft, maxLeft);

    return AnimatedScale(
      scale: _isInteracting ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Container(
        height: 52, // Match comfortable touch target size
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212).withValues(alpha: 0.88) : const Color(0xFFFFFFFF).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(100),
          border: isDark ? null : Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.6),
            width: 0.5,
          ),

        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              int index = (details.localPosition.dx / layoutWidth).floor().clamp(0, itemCount - 1);
              setState(() {
                _localLockedIndex = index;
                _isInteracting = false;
                _dragOffset = null;
                _hoverIndex = null;
              });
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) widget.onValueChanged(index);
              });
            },
            onHorizontalDragDown: (details) {
              setState(() {
                _isInteracting = true;
                _hoverIndex = (details.localPosition.dx / layoutWidth).floor().clamp(0, itemCount - 1);
                double slotCenter = (_hoverIndex! * layoutWidth) + (layoutWidth / 2);
                _touchOffsetFromCenter = details.localPosition.dx - slotCenter;
                _dragOffset = null;
              });
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                double targetCenter = details.localPosition.dx - _touchOffsetFromCenter;
                _dragOffset = targetCenter;
                _hoverIndex = (targetCenter / layoutWidth).floor().clamp(0, itemCount - 1);
              });
            },
            onHorizontalDragEnd: (details) {
              int? finalIndex = _hoverIndex;
              setState(() {
                if (finalIndex != null) {
                  _localLockedIndex = finalIndex;
                }
                _isInteracting = false;
                _dragOffset = null;
                _hoverIndex = null;
              });
              if (finalIndex != null) {
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted) widget.onValueChanged(finalIndex);
                });
              }
            },
            onHorizontalDragCancel: () {
              setState(() {
                _isInteracting = false;
                _dragOffset = null;
                _hoverIndex = null;
              });
            },
            child: SizedBox(
              width: layoutWidth * itemCount,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedPositioned(
                    duration: (_isInteracting && _dragOffset != null)
                        ? Duration.zero
                        : const Duration(milliseconds: 150),
                    curve: (_isInteracting && _dragOffset != null)
                        ? Curves.linear
                        : Curves.easeOutCubic,
                    left: targetLeft,
                    top: 0,
                    bottom: 0,
                    width: bgWidth,
                    child: AnimatedScale(
                      scale: _isInteracting ? 1.05 : 1.0, // Subdued inner zoom
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF212121).withValues(alpha: 0.95) : const Color(0xFFE5E5E5).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: isDark ? null : [
                            BoxShadow(
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                              color: Colors.black.withValues(alpha: 0.04),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(itemCount, (index) {
                      final isActive = index == activeVisualIndex;
                      final color = isActive
                          ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                          : (isDark ? Colors.grey.shade500 : const Color(0xFF7C7C80));

                      final item = widget.items[index];

                      return SizedBox(
                        width: layoutWidth,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.svgString != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: SvgPicture.string(
                                    isActive ? (item.activeSvgString ?? item.svgString!) : item.svgString!,
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                                  ),
                                )
                              else if (item.icon != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Icon(
                                    isActive ? (item.activeIcon ?? item.icon) : item.icon,
                                    size: 16,
                                    color: color,
                                  ),
                                ),
                              Flexible(
                                child: Text(
                                  item.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
