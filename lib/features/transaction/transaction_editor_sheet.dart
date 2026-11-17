import 'package:flutter/material.dart';

import '../../core/enums/transaction_type.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/cash_flow_data.dart';
import '../../models/transaction.dart';

class TransactionEditorSheet extends StatefulWidget {
  final CashFlowData data;

  const TransactionEditorSheet({super.key, required this.data});

  @override
  State<TransactionEditorSheet> createState() => _TransactionEditorSheetState();
}

class _TransactionEditorSheetState extends State<TransactionEditorSheet> {
  late TransactionType _type;
  late String _walletId;
  late String _categoryId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = TransactionType.expense;
    _walletId = widget.data.wallets.isNotEmpty
        ? widget.data.wallets.first.id
        : '';
    _categoryId = widget.data.categoriesByType(_type).isNotEmpty
        ? widget.data.categoriesByType(_type).first.id
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.data.categoriesByType(_type);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tambah Transaksi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
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
                onSelectionChanged: (values) {
                  setState(() {
                    _type = values.first;
                    final list = widget.data.categoriesByType(_type);
                    if (list.isNotEmpty) {
                      _categoryId = list.first.id;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Nominal'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final today = DateUtils.dateOnly(DateTime.now());
                  final date = await showDatePicker(
                    context: context,
                    initialDate: today,
                    firstDate: DateTime(2020),
                    lastDate: today,
                    helpText: 'Pilih tanggal transaksi',
                  );
                  if (date != null) {
                    setState(() => _date = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal'),
                  child: Text(
                    formatDate(_date),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _walletId.isEmpty ? null : _walletId,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                items: widget.data.wallets
                    .map(
                      (wallet) => DropdownMenuItem(
                        value: wallet.id,
                        child: Text(wallet.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _walletId = value ?? ''),
                decoration: const InputDecoration(labelText: 'Wallet'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoryId.isEmpty ? null : _categoryId,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value ?? ''),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text) ?? 0;
                    if (amount <= 0 ||
                        _walletId.isEmpty ||
                        _categoryId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nominal, wallet, dan kategori wajib diisi.',
                          ),
                        ),
                      );
                      return;
                    }

                    widget.data.addTransaction(
                      Transaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        walletId: _walletId,
                        categoryId: _categoryId,
                        type: _type,
                        amount: amount,
                        date: _date,
                        description: _descriptionController.text,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
