import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/models/app_mode.dart';

class ModeSelectorScreen extends StatefulWidget {
  const ModeSelectorScreen({
    super.key,
    required this.onModeSelected,
  });

  final ValueChanged<AppMode> onModeSelected;

  @override
  State<ModeSelectorScreen> createState() => _ModeSelectorScreenState();
}

class _ModeSelectorScreenState extends State<ModeSelectorScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSelect(AppMode mode) {
    setState(() {
      _isFadingOut = true;
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      widget.onModeSelected(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Force dark mode look for premium cinematic feel, matching React
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF0F2F5);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return AnimatedOpacity(
      opacity: _isFadingOut ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Who is working today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your operating mode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 64),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ModeCard(
                      title: 'Niril Silk',
                      icon: CupertinoIcons.doc_text_fill,
                      isDark: isDark,
                      onTap: () => _handleSelect(AppMode.gst),
                    ),
                    const SizedBox(width: 32),
                    _ModeCard(
                      title: 'Niril Coolie',
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      isDark: isDark,
                      onTap: () => _handleSelect(AppMode.coolie),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  const _ModeCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final boxBg = widget.isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE);
    final iconColor = widget.isDark ? Colors.white : Colors.black;
    final textColor = widget.isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    final textHoverColor = widget.isDark ? Colors.white : const Color(0xFF111827);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -8.0 : 0, 0)..scale(_isHovered ? 1.05 : 1.0),
          width: 160,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: boxBg,
                  border: Border.all(
                    color: _isHovered ? (widget.isDark ? Colors.white : Colors.black) : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: widget.isDark ? 0.4 : 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
                        ],
                ),
                child: Icon(
                  widget.icon,
                  size: 56,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _isHovered ? textHoverColor : textColor,
                ),
                child: Text(widget.title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
