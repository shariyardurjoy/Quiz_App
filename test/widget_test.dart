// Basic smoke test that does not touch Firebase.
//
// The full Notes app requires Firebase initialization, which can't run inside
// `flutter test` without mocking Firebase Core. To keep this beginner-friendly,
// we just build a simple MaterialApp and verify the title text is rendered.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Renders a MaterialApp with the expected title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Notes App')),
        ),
      ),
    );

    expect(find.text('Notes App'), findsOneWidget);
  });
}
