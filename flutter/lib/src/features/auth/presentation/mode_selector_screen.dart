import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/models/app_mode.dart';

class ModeSelectorScreen extends StatelessWidget {
  const ModeSelectorScreen({
    super.key,
    required this.onModeSelected,
  });

  final ValueChanged<AppMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    // Force dark mode look for premium cinematic feel, matching React/Netflix
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6); // Netflix dark is #141414
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Who's working today?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your operating mode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: subtextColor,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NetflixProfileCard(
                    title: 'Niril Silk',
                    icon: CupertinoIcons.doc_text_fill,
                    boxColor: isDark ? const Color(0xFF2C3E50) : const Color(0xFF34495E),
                    isDark: isDark,
                    onTap: () => onModeSelected(AppMode.silk),
                  ),
                  const SizedBox(width: 40),
                  _NetflixProfileCard(
                    title: 'Niril Coolie',
                    icon: CupertinoIcons.money_dollar_circle_fill,
                    boxColor: isDark ? const Color(0xFF8E44AD) : const Color(0xFF9B59B6),
                    isDark: isDark,
                    onTap: () => onModeSelected(AppMode.coolie),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetflixProfileCard extends StatefulWidget {
  const _NetflixProfileCard({
    required this.title,
    required this.icon,
    required this.boxColor,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color boxColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_NetflixProfileCard> createState() => _NetflixProfileCardState();
}

class _NetflixProfileCardState extends State<_NetflixProfileCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final textHoverColor = widget.isDark ? Colors.white : Colors.black;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0, // Netflix scale down on press
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            // Netflix-style Square Avatar Box
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // Netflix standard outer radius
                border: Border.all(
                  color: _isHovered ? textHoverColor : Colors.transparent,
                  width: 4,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ]
                    : [],
              ),
              child: Material(
                color: widget.boxColor,
                borderRadius: BorderRadius.circular(4), // Inner radius matches outer-border width
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  // NATIVE ANDROID RIPPLE
                  onTap: widget.onTap,
                  onHighlightChanged: (isHighlighted) {
                    setState(() => _isPressed = isHighlighted);
                  },
                  splashColor: Colors.white.withValues(alpha: 0.3),
                  highlightColor: Colors.black.withValues(alpha: 0.1),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 72,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Netflix-style title
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: _isHovered ? textHoverColor : textColor,
              ),
              child: Text(widget.title),
            ),
          ],
        ),
      ),
    );
  }
}