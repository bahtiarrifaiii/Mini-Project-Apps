import 'package:flutter/material.dart';

import '../../core/enums/transaction_type.dart';
import '../../data/cash_flow_data.dart';
import '../../models/transaction.dart';
import '../../models/wallet.dart';

class WalletEditorSheet extends StatefulWidget {
  final CashFlowData data;

  const WalletEditorSheet({super.key, required this.data});

  @override
  State<WalletEditorSheet> createState() => _WalletEditorSheetState();
}

class _WalletEditorSheetState extends State<WalletEditorSheet> {
  final nameController = TextEditingController();
  final balanceController = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Wallet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Nama wallet'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: balanceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Saldo awal'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final balance = double.tryParse(balanceController.text) ?? 0;
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama wallet tidak boleh kosong.'),
                      ),
                    );
                    return;
                  }

                  final walletId =
                      DateTime.now().microsecondsSinceEpoch.toString();

                  widget.data.addWallet(
                    Wallet(
                      id: walletId,
                      name: name,
                      initialBalance: 0,
                    ),
                  );

                  // Saldo awal dicatat sebagai pemasukan agar ikut muncul
                  // pada grafik, tanpa menghitung saldo wallet dua kali.
                  if (balance > 0) {
                    final incomeCategory = widget.data.categoriesByType(
                      TransactionType.income,
                    ).first;
                    widget.data.addTransaction(
                      Transaction(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        walletId: walletId,
                        categoryId: incomeCategory.id,
                        type: TransactionType.income,
                        amount: balance,
                        date: DateTime.now(),
                        description: 'Saldo awal wallet',
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
