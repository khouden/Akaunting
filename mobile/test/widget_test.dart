import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/core/di/injection_container.dart' as di;

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await di.init();
    await tester.pumpWidget(const AkauntingMobileApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
