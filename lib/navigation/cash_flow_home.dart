import 'package:flutter/material.dart';

import '../data/cash_flow_data.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/transaction/transaction_screen.dart';
import '../features/budget/budget_screen.dart';
import '../features/category/category_screen.dart';
import '../features/transaction/transaction_editor_sheet.dart';
import '../widgets/bottom_navbar.dart';

class CashFlowHome extends StatefulWidget {
  final CashFlowData data;

  const CashFlowHome({super.key, required this.data});

  @override
  State<CashFlowHome> createState() => _CashFlowHomeState();
}

class _CashFlowHomeState extends State<CashFlowHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(data: widget.data),
      WalletScreen(data: widget.data),
      TransactionScreen(data: widget.data),
      BudgetScreen(data: widget.data),
      CategoryScreen(data: widget.data),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
        onAddPressed: () => _openTransactionEditor(context),
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: () => _openTransactionEditor(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _openTransactionEditor(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionEditorSheet(data: widget.data),
    );
  }
}
