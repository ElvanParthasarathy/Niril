import 'package:flutter/material.dart';
import '../../../shell/presentation/widgets/elvan_responsive_grid.dart';

class SilkHomePage extends StatelessWidget {
  const SilkHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      sliver: ElvanResponsiveGrid(
        itemCount: 50,
        desktopCrossAxisCount: 2,
        childAspectRatio: 2.5,
        itemBuilder: (context, index) {
          return Container(
            height: 100, // Used by mobile list
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('Silk Home Page - Item $index', style: TextStyle(color: Colors.blue.withOpacity(0.8), fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
