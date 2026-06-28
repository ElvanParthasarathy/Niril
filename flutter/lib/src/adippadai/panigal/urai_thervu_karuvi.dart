import 'package:flutter/material.dart';

Widget buildElvanContextMenu(
    BuildContext context, EditableTextState editableTextState) {
  final List<ContextMenuButtonItem> filteredButtons =
      editableTextState.contextMenuButtonItems.where((buttonItem) {
    return buttonItem.type == ContextMenuButtonType.cut ||
        buttonItem.type == ContextMenuButtonType.copy ||
        buttonItem.type == ContextMenuButtonType.paste ||
        buttonItem.type == ContextMenuButtonType.selectAll;
  }).toList();

  final cs = Theme.of(context).colorScheme;

  return TextSelectionToolbar(
    anchorAbove: editableTextState.contextMenuAnchors.primaryAnchor,
    anchorBelow: editableTextState.contextMenuAnchors.primaryAnchor,
    toolbarBuilder: (context, child) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.onSurface.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    },
    children: filteredButtons.map((button) {
      IconData icon;
      String label = '';
      switch (button.type) {
        case ContextMenuButtonType.cut:
          icon = Icons.content_cut_rounded;
          label = 'வெட்டு';
          break;
        case ContextMenuButtonType.copy:
          icon = Icons.content_copy_rounded;
          label = 'நகலெடு';
          break;
        case ContextMenuButtonType.paste:
          icon = Icons.content_paste_rounded;
          label = 'ஒட்டு';
          break;
        case ContextMenuButtonType.selectAll:
          icon = Icons.select_all_rounded;
          label = 'முழுதும் தேர்ந்தெடு';
          break;
        default:
          icon = Icons.touch_app;
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: button.onPressed,
          hoverColor: cs.onSurface.withValues(alpha: 0.05),
          splashColor: cs.onSurface.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}
