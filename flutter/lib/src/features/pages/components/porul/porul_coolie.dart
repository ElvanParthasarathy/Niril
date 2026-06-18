import 'package:flutter/material.dart';

class PorulCoolie extends StatelessWidget {
  const PorulCoolie({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 32,
        bottom: 120, // clearance for the floating pill
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'PorulCoolie Item ',
                  style: TextStyle(
                    color: Colors.green.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
          childCount: 50,
        ),
      ),
    );
  }
}