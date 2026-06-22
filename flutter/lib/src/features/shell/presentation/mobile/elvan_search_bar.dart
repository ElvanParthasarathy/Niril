import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../localization/locale_provider.dart';

class ElvanSearchBar extends ConsumerWidget {
  const ElvanSearchBar({
    super.key,
    required this.focusNode,
    required this.onChanged,
    required this.onClose,
    this.isExpanded = true,
  });

  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback onClose;
  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isExpanded ? 1.0 : 0.0,
          child: Row(
            children: [
              const Icon(CupertinoIcons.search, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'search'.tr(context, ref),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Icon(CupertinoIcons.clear_circled_solid,
                      size: 22, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
