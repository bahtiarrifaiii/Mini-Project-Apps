import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mini_proyek_apps/main.dart';

void main() {
  testWidgets('CashFlow app boots', (tester) async {
    await tester.pumpWidget(const CashFlowApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
