import 'package:flutter/material.dart';

/// பகுதித் தலைப்பு கூறு — Numbered section header matching React's
/// ElvanEditorLayout section badges.
///
/// Displays a numbered circle badge (24×24, primary bg) followed by
/// the section title text (17.6px, fontWeight 600).
class ElvanPagudhiThalaipu extends StatelessWidget {
  const ElvanPagudhiThalaipu({
    super.key,
    required this.en,
    required this.thalaipu,
  });

  /// Section number displayed in the circle badge.
  final int en;

  /// Section title text.
  final String thalaipu;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 24),
      child: Row(
        children: [
          // ── Numbered Circle Badge ──
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$en',
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 12.8, // 0.8rem
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Section Title ──
          Text(
            thalaipu,
            style: TextStyle(
              fontSize: 17.6, // 1.1rem
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
