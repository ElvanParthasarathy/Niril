import 'package:flutter/material.dart';

Widget buildElvanContextMenu(BuildContext context, EditableTextState editableTextState) {
  final List<ContextMenuButtonItem> filteredButtons = editableTextState.contextMenuButtonItems.where((buttonItem) {
    return buttonItem.type == ContextMenuButtonType.cut ||
           buttonItem.type == ContextMenuButtonType.copy ||
           buttonItem.type == ContextMenuButtonType.paste ||
           buttonItem.type == ContextMenuButtonType.selectAll;
  }).toList();

  return AdaptiveTextSelectionToolbar.buttonItems(
    anchors: editableTextState.contextMenuAnchors,
    buttonItems: filteredButtons,
  );
}
