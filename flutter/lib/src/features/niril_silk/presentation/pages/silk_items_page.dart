import 'package:flutter/material.dart';

class SilkItemsPage extends StatelessWidget {
  const SilkItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 32, bottom: 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('Silk Items Page - Item $index', style: TextStyle(color: Colors.blue.withValues(alpha: 0.8), fontSize: 16)),
            ),
          ),
          childCount: 50,
        ),
      ),
    );
  }
}
