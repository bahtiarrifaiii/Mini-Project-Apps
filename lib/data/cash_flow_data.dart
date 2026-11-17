import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/enums/transaction_type.dart';
import '../core/utils/date_formatter.dart';
import '../models/budget_setting.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';

class CashFlowData extends ChangeNotifier {
  static const _storageKey = 'cashflow_data_v1';

  List<Wallet> wallets = [];
  List<Category> categories = [];
  List<Transaction> transactions = [];
  BudgetSetting? monthlyBudget;
  bool isReady = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = prefs.getString(_storageKey);

    if (serialized == null || serialized.isEmpty) {
      _bootstrap();
      await save();
    } else {
      try {
        final json = jsonDecode(serialized);
        wallets = (json['wallets'] as List? ?? [])
            .map((item) => Wallet.fromJson(item as Map<String, dynamic>))
            .toList();
        categories = (json['categories'] as List? ?? [])
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
        transactions = (json['transactions'] as List? ?? [])
            .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
            .toList();
        final budget = json['monthlyBudget'];
        monthlyBudget = budget == null
            ? null
            : BudgetSetting.fromJson(budget as Map<String, dynamic>);
        if (categories.isEmpty) _bootstrapCategories();
      } catch (_) {
        _bootstrap();
        await save();
      }
    }

    isReady = true;
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'wallets': wallets.map((wallet) => wallet.toJson()).toList(),
        'categories': categories.map((category) => category.toJson()).toList(),
        'transactions': transactions
            .map((transaction) => transaction.toJson())
            .toList(),
        'monthlyBudget': monthlyBudget?.toJson(),
      }),
    );
  }

  Future<void> refresh() async {
    await save();
    notifyListeners();
  }

  void _bootstrap() {
    wallets = [Wallet(id: 'wallet-1', name: 'Cash', initialBalance: 0)];
    _bootstrapCategories();
    transactions = [];
    monthlyBudget = null;
  }

  void _bootstrapCategories() {
    categories = [
      const Category(
        id: 'income-1',
        name: 'Gaji',
        type: TransactionType.income,
        isDefault: true,
      ),
      const Category(
        id: 'income-2',
        name: 'Uang Saku',
        type: TransactionType.income,
        isDefault: true,
      ),
      const Category(
        id: 'income-3',
        name: 'Bonus',
        type: TransactionType.income,
        isDefault: true,
      ),
      const Category(
        id: 'expense-1',
        name: 'Makanan & Minuman',
        type: TransactionType.expense,
        isDefault: true,
      ),
      const Category(
        id: 'expense-2',
        name: 'Transportasi',
        type: TransactionType.expense,
        isDefault: true,
      ),
      const Category(
        id: 'expense-3',
        name: 'Belanja',
        type: TransactionType.expense,
        isDefault: true,
      ),
    ];
  }

  Wallet? findWallet(String id) {
    try {
      return wallets.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Category? findCategory(String id) {
    try {
      return categories.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Category> categoriesByType(TransactionType type) {
    return categories.where((category) => category.type == type).toList();
  }

  double walletBalance(Wallet wallet) {
    final income = transactions
        .where(
          (item) =>
              item.walletId == wallet.id && item.type == TransactionType.income,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expense = transactions
        .where(
          (item) =>
              item.walletId == wallet.id &&
              item.type == TransactionType.expense,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
    return wallet.initialBalance + income - expense;
  }

  double totalBalance() {
    return wallets.fold<double>(
      0,
      (sum, wallet) => sum + walletBalance(wallet),
    );
  }

  double totalIncomeThisMonth() {
    final now = DateTime.now();
    return transactions
        .where(
          (item) =>
              item.type == TransactionType.income &&
              item.date.year == now.year &&
              item.date.month == now.month,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double totalExpenseThisMonth() {
    final now = DateTime.now();
    return transactions
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.date.year == now.year &&
              item.date.month == now.month,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  BudgetSetting? currentBudget() {
    if (monthlyBudget == null) return null;
    final currentKey = monthKey(DateTime.now());
    return monthlyBudget!.monthKeyValue == currentKey ? monthlyBudget : null;
  }

  void setBudget(double limit) {
    monthlyBudget = BudgetSetting(
      monthKeyValue: monthKey(DateTime.now()),
      limit: limit,
    );
    save();
    notifyListeners();
  }

  List<Transaction> searchTransactions(String query) {
    final normalized = query.toLowerCase();
    final result = transactions.where((item) {
      final desc = item.description.toLowerCase();
      final category = findCategory(item.categoryId)?.name.toLowerCase() ?? '';
      return normalized.isEmpty ||
          desc.contains(normalized) ||
          category.contains(normalized);
    }).toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  void addWallet(Wallet wallet) {
    wallets.add(wallet);
    save();
    notifyListeners();
  }

  void updateWallet(String id, String newName, {int? themeColor}) {
    final index = wallets.indexWhere((w) => w.id == id);
    if (index != -1) {
      wallets[index] = Wallet(
        id: id,
        name: newName,
        initialBalance: wallets[index].initialBalance,
        themeColor: themeColor ?? wallets[index].themeColor,
      );
      save();
      notifyListeners();
    }
  }

  void deleteWallet(String id) {
    wallets.removeWhere((wallet) => wallet.id == id);
    transactions.removeWhere((transaction) => transaction.walletId == id);
    save();
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
    save();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((transaction) => transaction.id == id);
    save();
    notifyListeners();
  }

  DateTime earliestTransactionMonth() {
    if (transactions.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, 1);
    }

    final earliest = transactions
        .map((item) => item.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime(earliest.year, earliest.month, 1);
  }

  List<DateTime> availableChartMonths() {
    final now = DateTime.now();
    final first = earliestTransactionMonth();
    final months = <DateTime>[];

    var cursor = DateTime(now.year, now.month, 1);
    final earliestMonth = DateTime(first.year, first.month, 1);

    while (!cursor.isBefore(earliestMonth)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month - 1, 1);
    }
    return months;
  }

  double chartTotal(DateTime month, TransactionType type) {
    return transactions
        .where(
          (item) =>
              item.type == type &&
              item.date.year == month.year &&
              item.date.month == month.month,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  List<double> weeklyChartTotals(DateTime month, TransactionType type) {
    final totals = <double>[0, 0, 0, 0];

    for (final item in transactions) {
      if (item.type != type ||
          item.date.year != month.year ||
          item.date.month != month.month) {
        continue;
      }

      final weekIndex = ((item.date.day - 1) ~/ 7).clamp(0, 3).toInt();
      totals[weekIndex] += item.amount;
    }

    return totals;
  }

  List<String> weeklyChartLabels(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(4, (index) {
      final startDay = index * 7 + 1;
      final endDay = index == 3 ? daysInMonth : (startDay + 6);
      return '$startDay–$endDay';
    });
  }
}
