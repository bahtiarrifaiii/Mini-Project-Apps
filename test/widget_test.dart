import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mini_proyek_apps/app/cash_flow_app.dart';
import 'package:mini_proyek_apps/data/cash_flow_data.dart';
import 'package:mini_proyek_apps/features/wallet/wallet_editor_sheet.dart';
import 'package:mini_proyek_apps/features/wallet/wallet_theme.dart';
import 'package:mini_proyek_apps/models/wallet.dart';

void main() {
  testWidgets('CashFlow app boots', (tester) async {
    await tester.pumpWidget(const CashFlowApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  test('Wallet theme color persists and legacy wallets use the default', () {
    final wallet = Wallet(
      id: 'wallet-1',
      name: 'Cash',
      initialBalance: 0,
      themeColor: walletThemeColors[1].toARGB32(),
    );

    expect(Wallet.fromJson(wallet.toJson()).themeColor, wallet.themeColor);
    expect(
      Wallet.fromJson({'id': 'legacy', 'name': 'Old wallet'}).themeColor,
      defaultWalletThemeColor,
    );
  });

  testWidgets('Wallet editor saves the selected theme', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final data = CashFlowData();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => WalletEditorSheet(data: data),
              ),
              child: const Text('Open wallet editor'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open wallet editor'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Tabungan');
    await tester.ensureVisible(find.bySemanticsLabel('Pilihan tema 2'));
    await tester.tap(find.bySemanticsLabel('Pilihan tema 2'));
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(data.wallets.single.name, 'Tabungan');
    expect(data.wallets.single.themeColor, walletThemeColors[1].toARGB32());
  });
}
