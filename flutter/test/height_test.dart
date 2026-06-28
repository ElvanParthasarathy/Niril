import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('InputDecorator height test', (WidgetTester tester) async {
    final key1 = GlobalKey();
    final key2 = GlobalKey();
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            TextFormField(
              key: key1,
              decoration: const InputDecoration(
                constraints: BoxConstraints.tightFor(height: 48),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            InputDecorator(
              key: key2,
              decoration: const InputDecoration(
                constraints: BoxConstraints.tightFor(height: 48),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(),
              ),
              child: const Row(
                children: [
                  Text('Dropdown', style: TextStyle(fontSize: 14)),
                  Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
    
    final size1 = tester.getSize(find.byKey(key1));
    final size2 = tester.getSize(find.byKey(key2));
    
    print('TextFormField height: ${size1.height}');
    print('InputDecorator height: ${size2.height}');
  });
}
