import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';
import '../../data/cash_flow_data.dart';

class BudgetScreen extends StatefulWidget {
  final CashFlowData data;

  const BudgetScreen({super.key, required this.data});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final budget = widget.data.currentBudget();
    final spent = widget.data.totalExpenseThisMonth();
    final ratio = budget == null ? 0.0 : (spent / budget.limit).clamp(0.0, 1.5);

    return Scaffold(
      appBar: AppBar(title: const Text('Anggaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Batas Bulanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      budget == null
                          ? 'Belum ditetapkan'
                          : formatCurrency(budget.limit),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: ratio,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Terpakai: ${formatCurrency(spent)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Nominal anggaran bulan ini',
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final value = double.tryParse(controller.text) ?? 0;
                  if (value > 0) {
                    widget.data.setBudget(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anggaran tersimpan.')),
                    );
                  }
                },
                child: const Text('Simpan Anggaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
