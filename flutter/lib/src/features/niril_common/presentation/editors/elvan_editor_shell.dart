import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../shell/presentation/mobile/elvan_subpage_shell.dart';

/// The Universal Editor Shell that wraps all creator/editor forms.
class ElvanEditorShell extends StatelessWidget {
  const ElvanEditorShell({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return ElvanSubpageShell(
      title: title,
      navActions: [
        if (onSave != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onSave,
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ],
    );
  }
}
