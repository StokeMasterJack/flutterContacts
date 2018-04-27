import 'package:blackjack/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(new App(
      shuffle: false,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('Text Blackjack'), findsOneWidget);
    expect(find.text('Graphic Blackjack'), findsOneWidget);
    expect(find.text('Press Hit or Stay'), findsNothing);

    await tester.tap(find.byKey(new Key("Text")));

    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Press Hit or Stay'), findsOneWidget);
    expect(find.text('Hit'), findsOneWidget);

    expect(find.text('4 points'), findsOneWidget);
    expect(find.text('6 points'), findsOneWidget);

    await tester.tap(find.byKey(new Key("Hit")));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('9 points'), findsOneWidget);
    expect(find.text('6 points'), findsOneWidget);

    await tester.tap(find.byKey(new Key("Stay")));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('9 points'), findsOneWidget);
    expect(find.text('19 points'), findsOneWidget);
  });
}
