import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('measure heights', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('text'),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  filled: true,
                ),
                style: const TextStyle(fontSize: 14),
              ),
              InputDecorator(
                key: const Key('decorator'),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  filled: true,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.payment, size: 14),
                    SizedBox(width: 8),
                    Text('Some text', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));

    final textSize = tester.getSize(find.byKey(const Key('text')));
    final decoratorSize = tester.getSize(find.byKey(const Key('decorator')));
    
    print('TextFormField height: $');
    print('InputDecorator height: $');
  });
}
