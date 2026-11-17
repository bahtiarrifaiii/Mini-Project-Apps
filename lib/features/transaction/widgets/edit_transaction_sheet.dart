import 'package:flutter/material.dart';

import '../../../core/enums/transaction_type.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/cash_flow_data.dart';
import '../../../models/transaction.dart';

class EditTransactionSheet extends StatefulWidget {
  final CashFlowData data;
  final Transaction transaction;

  const EditTransactionSheet({
    super.key,
    required this.data,
    required this.transaction,
  });

  static Future<bool?> show(
    BuildContext context, {
    required CashFlowData data,
    required Transaction transaction,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EditTransactionSheet(
        data: data,
        transaction: transaction,
      ),
    );
  }

  @override
  State<EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<EditTransactionSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late TransactionType _type;
  late String _walletId;
  late String _categoryId;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _amountController =
        TextEditingController(text: transaction.amount.toStringAsFixed(0));
    _descriptionController =
        TextEditingController(text: transaction.description);
    _type = transaction.type;
    _walletId = transaction.walletId;
    _categoryId = transaction.categoryId;
    _date = transaction.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.data.categoriesByType(_type);
    if (!categories.any((category) => category.id == _categoryId)) {
      _categoryId = categories.isEmpty ? '' : categories.first.id;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Edit Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Pemasukan'),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Pengeluaran'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() {
                  _type = selection.first;
                  final list = widget.data.categoriesByType(_type);
                  _categoryId = list.isEmpty ? '' : list.first.id;
                });
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: widget.data.wallets.any((w) => w.id == _walletId)
                  ? _walletId
                  : null,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Wallet'),
              items: widget.data.wallets
                  .map((wallet) => DropdownMenuItem(
                      value: wallet.id, child: Text(wallet.name)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _walletId = value ?? ''),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoryId.isEmpty ? null : _categoryId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: categories
                  .map((category) => DropdownMenuItem(
                      value: category.id, child: Text(category.name)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _categoryId = value ?? ''),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final today = DateUtils.dateOnly(DateTime.now());
                final safeInitialDate = _date.isAfter(today) ? today : _date;
                final picked = await showDatePicker(
                  context: context,
                  initialDate: safeInitialDate,
                  firstDate: DateTime(2000),
                  lastDate: today,
                  helpText: 'Pilih tanggal transaksi',
                );
                if (picked != null) setState(() => _date = picked);
              },
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(formatDate(_date)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0 || _walletId.isEmpty || _categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal, wallet, dan kategori wajib diisi.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final index = widget.data.transactions
        .indexWhere((item) => item.id == widget.transaction.id);
    if (index == -1) {
      setState(() => _saving = false);
      return;
    }

    widget.data.transactions[index] = Transaction(
      id: widget.transaction.id,
      walletId: _walletId,
      categoryId: _categoryId,
      type: _type,
      amount: amount,
      date: _date,
      description: _descriptionController.text.trim(),
    );

    await widget.data.save();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}
