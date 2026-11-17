import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';

class TransactionSummaryCard extends StatelessWidget {
  final int count;
  final double income;
  final double expense;

  const TransactionSummaryCard({
    super.key,
    required this.count,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF202124),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(child: _summaryItem('Transaksi', '$count', Colors.white)),
          _summaryDivider(),
          Expanded(
            child: _summaryItem(
              'Pemasukan',
              '+${formatCurrency(income)}',
              const Color(0xFF55C98A),
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryItem(
              'Pengeluaran',
              '-${formatCurrency(expense)}',
              const Color(0xFFFF7777),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() =>
      Container(width: 1, height: 34, color: Colors.white12);

  Widget _summaryItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Colors.white54),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
