import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../localization/locale_provider.dart';
import '../../../auth/presentation/mode_selector_screen.dart';
import '../../../../core/state/app_state.dart';

class VanakkamPill extends ConsumerWidget {
  final String subtitleKey;

  const VanakkamPill({
    super.key,
    this.subtitleKey = 'nirilSilk',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: isMobile ? double.infinity : null,
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
            padding: EdgeInsets.only(
              left: isMobile ? 16 : 12,
              top: isMobile ? 16 : 12,
              bottom: isMobile ? 16 : 12,
              right: 32,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111111) : Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(right: isMobile ? 20 : 16),
                  child: Material(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                ModeSelectorScreen(
                              onModeSelected: (selectedMode) {
                                ref.read(appModeProvider.notifier).setMode(selectedMode);
                                Navigator.of(context).pop();
                              },
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: SizedBox(
                        width: isMobile ? 60 : 48,
                        height: isMobile ? 60 : 48,
                        child: Center(
                          child: Icon(
                            Icons.receipt_long,
                            size: isMobile ? 24 : 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'vanakkamTitle'.tr(context, ref),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.02,
                            height: 1.2,
                            fontSize: isMobile ? 22 : 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: Color(0xFFFFC107),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleKey.tr(context, ref),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF9BA1A6) : const Color(0xFF666666),
                        fontSize: isMobile ? 16.8 : 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
