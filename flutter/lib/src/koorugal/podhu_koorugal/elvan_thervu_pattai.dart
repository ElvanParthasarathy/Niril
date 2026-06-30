import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adippadai/mozhiyaakkam/k.dart';
import '../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

/// A shared bulk selection action bar used across list screens.
class ElvanThervuPattai extends ConsumerWidget {
  const ElvanThervuPattai({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDelete,
    required this.onCancel,
  });

  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E).withValues(alpha: 0.88)
            : const Color(0xFFFFFFFF).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark
              ? const Color(0xFF333333).withValues(alpha: 0.6)
              : const Color(0xFFFFFFFF).withValues(alpha: 0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Row(
          children: [
            // Checkbox + count
            GestureDetector(
              onTap: onSelectAll,
              child: Row(
                children: [
                  Icon(
                    selectedCount > 0
                        ? CupertinoIcons.checkmark_square_fill
                        : CupertinoIcons.square,
                    size: 22,
                    color: selectedCount > 0
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? Colors.white38 : Colors.black38),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$selectedCount ${K.thaerndhedu.tr(context, ref)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Cancel button
            GestureDetector(
              onTap: onCancel,
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 24,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(width: 12),
            // Delete button
            GestureDetector(
              onTap: selectedCount > 0 ? onDelete : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedCount > 0
                      ? Colors.red.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  CupertinoIcons.trash,
                  size: 20,
                  color: selectedCount > 0
                      ? Colors.red
                      : (isDark ? Colors.white24 : Colors.black26),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
