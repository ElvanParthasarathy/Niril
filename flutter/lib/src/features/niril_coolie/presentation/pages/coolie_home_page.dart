import 'package:flutter/material.dart';
import '../../../shell/presentation/widgets/elvan_responsive_grid.dart';

class CoolieHomePage extends StatelessWidget {
  const CoolieHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      sliver: ElvanResponsiveGrid(
        itemCount: 50,
        desktopCrossAxisCount: 2,
        childAspectRatio: 2.5, // Make items wider on grid
        itemBuilder: (context, index) {
          return Container(
            height: 100, // Used by mobile list
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('Coolie Home Page - Item $index', style: TextStyle(color: Colors.orange.withOpacity(0.8), fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
