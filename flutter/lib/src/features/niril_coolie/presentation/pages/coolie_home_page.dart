import 'package:flutter/material.dart';

class CoolieHomePage extends StatelessWidget {
  const CoolieHomePage({super.key});

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
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('Coolie Home Page - Item $index', style: TextStyle(color: Colors.orange.withValues(alpha: 0.8), fontSize: 16)),
            ),
          ),
          childCount: 50,
        ),
      ),
    );
  }
}
