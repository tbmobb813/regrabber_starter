import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regrabber/screens/home/home_screen.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  });
}
