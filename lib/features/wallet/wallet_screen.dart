import 'package:flutter/material.dart';

import '../../core/enums/transaction_type.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/cash_flow_data.dart';
import '../../models/transaction.dart';
import '../../models/wallet.dart';
import 'wallet_editor_sheet.dart';
import 'wallet_theme.dart';

class WalletScreen extends StatelessWidget {
  final CashFlowData data;

  const WalletScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (data.wallets.isEmpty)
            const Center(child: Text('Belum ada wallet.'))
          else
            ...data.wallets.map(
              (wallet) => Card(
                color: walletColor(wallet),
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: walletColor(wallet),
                    image: walletThemeDecorationImage(wallet.themeImageBase64),
                  ),
                  child: ListTile(
                    leading: const WalletBrandMark(size: 42),
                    title: Text(
                      wallet.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: walletTextColor(wallet),
                      ),
                    ),
                    subtitle: Text(
                      formatCurrency(data.walletBalance(wallet)),
                      style: TextStyle(
                        color: walletTextColor(wallet).withValues(alpha: 0.7),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Tambah saldo',
                          onPressed: () => _addWalletBalance(context, wallet),
                          icon: Icon(Icons.add, color: walletTextColor(wallet)),
                        ),
                        IconButton(
                          tooltip: 'Ubah wallet',
                          icon: Icon(
                            Icons.edit_outlined,
                            color: walletTextColor(wallet),
                          ),
                          onPressed: () => _showWalletEditor(context, wallet),
                        ),
                        IconButton(
                          tooltip: 'Hapus wallet',
                          icon: Icon(
                            Icons.delete_outline,
                            color: walletTextColor(wallet),
                          ),
                          onPressed: () => _confirmDelete(context, wallet),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWalletEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addWalletBalance(BuildContext context, Wallet wallet) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) =>
          _AddWalletBalanceDialog(walletName: wallet.name),
    );

    if (!context.mounted || amount == null) return;

    final incomeCategories = data.categoriesByType(TransactionType.income);
    if (incomeCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori pemasukan belum tersedia.')),
      );
      return;
    }

    data.addTransaction(
      Transaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        walletId: wallet.id,
        categoryId: incomeCategories.first.id,
        type: TransactionType.income,
        amount: amount,
        date: DateTime.now(),
        description: 'Tambah saldo wallet',
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Wallet wallet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus wallet?'),
        content: Text('Hapus ${wallet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      data.deleteWallet(wallet.id);
    }
  }

  Future<void> _showWalletEditor(BuildContext context, [Wallet? wallet]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WalletEditorSheet(data: data, wallet: wallet),
    );
  }
}

class _AddWalletBalanceDialog extends StatefulWidget {
  final String walletName;

  const _AddWalletBalanceDialog({required this.walletName});

  @override
  State<_AddWalletBalanceDialog> createState() =>
      _AddWalletBalanceDialogState();
}

class _AddWalletBalanceDialogState extends State<_AddWalletBalanceDialog> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal yang valid.')),
      );
      return;
    }

    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah saldo ${widget.walletName}'),
      content: TextField(
        controller: _amountController,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Nominal pemasukan',
          prefixText: 'Rp ',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
