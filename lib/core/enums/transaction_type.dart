import 'package:flutter/material.dart';

enum TransactionType { income, expense }

extension TransactionTypeX on TransactionType {
  String get label =>
      this == TransactionType.income ? 'Pemasukan' : 'Pengeluaran';
  String get storageValue =>
      this == TransactionType.income ? 'income' : 'expense';
  Color get color => this == TransactionType.income ? Colors.green : Colors.red;
  IconData get icon => this == TransactionType.income
      ? Icons.arrow_downward_rounded
      : Icons.arrow_upward_rounded;

  static TransactionType fromString(String value) {
    return value == 'income' ? TransactionType.income : TransactionType.expense;
  }
}
