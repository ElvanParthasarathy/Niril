import 'package:flutter/material.dart';

class ElvanMaeladukkuThalaipu extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const ElvanMaeladukkuThalaipu({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
