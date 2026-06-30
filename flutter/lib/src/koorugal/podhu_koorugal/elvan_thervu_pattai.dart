import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adippadai/mozhiyaakkam/k.dart';
import '../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../cheyalpaadugal/chattagam/kaatchi/kaippaesi/elvan_chattagam.dart';
import 'elvan_kizh_pattai_base.dart';

/// A shared bulk selection action bar used across list screens.
class ElvanThervuPattai extends ConsumerWidget {
  const ElvanThervuPattai({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDelete,
    required this.onCancel,
    this.isExpanded = true,
  });

  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;
  final VoidCallback onCancel;
  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool effectiveExpanded = ElvanOverlayState.of(context)?.isExpanded ?? isExpanded;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElvanKizhPattaiBase(
      horizontalPadding: 16.0,
      verticalPadding: 6.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: effectiveExpanded ? 1.0 : 0.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAction(
              context: context,
              ref: ref,
              icon: selectedCount > 0
                  ? CupertinoIcons.checkmark_square_fill
                  : CupertinoIcons.square,
              label: selectedCount > 0
                  ? '$selectedCount ${K.thaerndhedu.tr(context, ref)}'
                  : K.anaithaiyumTheriPtn.tr(context, ref),
              onTap: onSelectAll,
              isDark: isDark,
              activeColor: selectedCount > 0
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            _buildAction(
              context: context,
              ref: ref,
              icon: CupertinoIcons.trash,
              label: K.neekkuPtn.tr(context, ref),
              onTap: selectedCount > 0 ? onDelete : null,
              isDark: isDark,
              activeColor: Colors.redAccent,
              isDisabled: selectedCount == 0,
            ),
            _buildAction(
              context: context,
              ref: ref,
              icon: CupertinoIcons.xmark_circle,
              label: K.kaividuPtn.tr(context, ref),
              onTap: onCancel,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
    Color? activeColor,
    bool isDisabled = false,
  }) {
    final color = isDisabled
        ? (isDark ? Colors.white24 : Colors.black26)
        : (activeColor ?? (isDark ? Colors.white : Colors.black87));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
