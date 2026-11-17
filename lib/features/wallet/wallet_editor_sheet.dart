import 'package:flutter/material.dart';

import '../../core/enums/transaction_type.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/cash_flow_data.dart';
import '../../models/transaction.dart';
import '../../models/wallet.dart';
import 'wallet_theme.dart';

class WalletEditorSheet extends StatefulWidget {
  final CashFlowData data;
  final Wallet? wallet;

  const WalletEditorSheet({super.key, required this.data, this.wallet});

  @override
  State<WalletEditorSheet> createState() => _WalletEditorSheetState();
}

class _WalletEditorSheetState extends State<WalletEditorSheet> {
  late final TextEditingController nameController;
  late final TextEditingController balanceController;
  late int selectedThemeColor;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wallet?.name ?? '');
    balanceController = TextEditingController(text: '0');
    selectedThemeColor = widget.wallet?.themeColor ?? defaultWalletThemeColor;
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                widget.wallet == null ? 'Tambah Wallet' : 'Ubah Wallet',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nama wallet'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tema & Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _buildPreview(),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Pilih warna dasar kartu wallet',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.15,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: walletThemeColors.asMap().entries.map((entry) {
                  final color = entry.value;
                  final isSelected = color.toARGB32() == selectedThemeColor;
                  return Semantics(
                    label: 'Pilihan tema ${entry.key + 1}',
                    selected: isSelected,
                    button: true,
                    child: InkWell(
                      onTap: () =>
                          setState(() => selectedThemeColor = color.toARGB32()),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white24,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF202020),
                                size: 23,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (widget.wallet == null) ...[
                const SizedBox(height: 18),
                TextField(
                  controller: balanceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Saldo awal (opsional)',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveWallet,
                  child: Text(
                    widget.wallet == null ? 'Simpan' : 'Simpan Perubahan',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final theme = Color(selectedThemeColor);
    final textColor = theme.computeLuminance() > 0.45
        ? const Color(0xFF202020)
        : Colors.white;
    final previewBalance = widget.wallet == null
        ? (double.tryParse(
                balanceController.text.trim().replaceAll(',', '.'),
              ) ??
              0)
        : widget.data.walletBalance(widget.wallet!);

    return AspectRatio(
      aspectRatio: 1.85,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: theme.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const WalletBrandMark(size: 42),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'WALLET',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameController.text.trim().isEmpty
                      ? 'Nama Wallet'
                      : nameController.text.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatCurrency(previewBalance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveWallet() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama wallet tidak boleh kosong.')),
      );
      return;
    }

    final existingWallet = widget.wallet;
    if (existingWallet != null) {
      widget.data.updateWallet(
        existingWallet.id,
        name,
        themeColor: selectedThemeColor,
      );
      Navigator.pop(context);
      return;
    }

    final balance =
        double.tryParse(balanceController.text.trim().replaceAll(',', '.')) ??
        0;
    final incomeCategories = widget.data.categoriesByType(
      TransactionType.income,
    );
    if (balance > 0 && incomeCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori pemasukan belum tersedia.')),
      );
      return;
    }

    final walletId = DateTime.now().microsecondsSinceEpoch.toString();
    widget.data.addWallet(
      Wallet(
        id: walletId,
        name: name,
        initialBalance: 0,
        themeColor: selectedThemeColor,
      ),
    );

    if (balance > 0) {
      widget.data.addTransaction(
        Transaction(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          walletId: walletId,
          categoryId: incomeCategories.first.id,
          type: TransactionType.income,
          amount: balance,
          date: DateTime.now(),
          description: 'Saldo awal wallet',
        ),
      );
    }
    Navigator.pop(context);
  }
}
