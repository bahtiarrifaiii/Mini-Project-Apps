import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/enums/transaction_type.dart';
import '../../data/cash_flow_data.dart';
import '../../models/transaction.dart';
import 'transaction_editor_sheet.dart';
import 'widgets/edit_transaction_sheet.dart';
import 'widgets/transaction_card.dart';
import 'widgets/transaction_empty_state.dart';
import 'widgets/transaction_filters.dart';
import 'widgets/transaction_header.dart';
import 'widgets/transaction_search_bar.dart';
import 'widgets/transaction_summary_card.dart';

class TransactionScreen extends StatefulWidget {
  final CashFlowData data;

  const TransactionScreen({super.key, required this.data});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TransactionType? _typeFilter;
  String? _categoryFilter;
  String _timeFilter = 'all';
  DateTimeRange? _selectedRange;

  CashFlowData get data => widget.data;

  @override
  void initState() {
    super.initState();
    data.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    data.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hari ini';
    }
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Kemarin';
    }
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  Future<void> _openAddEditor(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionEditorSheet(data: data),
    );
  }

  Future<void> _confirmDelete(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text('Transaksi yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) data.deleteTransaction(transaction.id);
  }

  Future<void> _openEditEditor(Transaction transaction) async {
    final updated = await EditTransactionSheet.show(
      context,
      data: data,
      transaction: transaction,
    );

    if (updated == true && mounted) {
      await data.refresh();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(now);
    final categories = data.categories
        .where(
          (category) => _typeFilter == null || category.type == _typeFilter,
        )
        .toList();

    if (_categoryFilter != null &&
        !categories.any((category) => category.id == _categoryFilter)) {
      _categoryFilter = null;
    }

    final transactions = data.searchTransactions(_query).where((item) {
      final matchesType = _typeFilter == null || item.type == _typeFilter;
      final matchesCategory =
          _categoryFilter == null || item.categoryId == _categoryFilter;
      bool matchesTime = true;
      if (_timeFilter == 'month') {
        matchesTime =
            item.date.year == now.year && item.date.month == now.month;
      } else if (_timeFilter == 'range' && _selectedRange != null) {
        final start = DateTime(
          _selectedRange!.start.year,
          _selectedRange!.start.month,
          _selectedRange!.start.day,
        );
        final end = DateTime(
          _selectedRange!.end.year,
          _selectedRange!.end.month,
          _selectedRange!.end.day,
          23,
          59,
          59,
        );
        matchesTime = !item.date.isBefore(start) && !item.date.isAfter(end);
      }
      return matchesType && matchesCategory && matchesTime;
    }).toList();

    final income = transactions
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expense = transactions
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final grouped = <String, List<Transaction>>{};
    for (final item in transactions) {
      final key = DateFormat('yyyy-MM-dd').format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    final dayKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 32, 20, 8),
                child: TransactionHeader(),
              ),
              TransactionSearchBar(
                controller: _searchController,
                query: _query,
                onChanged: (value) => setState(() => _query = value),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
              TransactionFilters(
                typeFilter: _typeFilter,
                onTypeFilterChanged: (type) {
                  setState(() {
                    _typeFilter = type;
                    _categoryFilter = null;
                  });
                },
                timeFilter: _timeFilter,
                onTimeFilterChanged: (value) {
                  setState(() {
                    _timeFilter = value;
                    if (value != 'range') _selectedRange = null;
                  });
                },
                selectedRange: _selectedRange,
                onRangeChanged: (range) =>
                    setState(() => _selectedRange = range),
                categoryFilter: _categoryFilter,
                onCategoryFilterChanged: (id) =>
                    setState(() => _categoryFilter = id),
                categories: categories,
                monthLabel: monthLabel,
              ),
              TransactionSummaryCard(
                count: transactions.length,
                income: income,
                expense: expense,
              ),
              if (transactions.isEmpty)
                const TransactionEmptyState()
              else
                ...dayKeys.map((key) {
                  final date = DateTime.parse(key);
                  final items = grouped[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          _dayLabel(date),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      ...items.map(
                        (tx) => TransactionCard(
                          transaction: tx,
                          wallet: data.findWallet(tx.walletId),
                          category: data.findCategory(tx.categoryId),
                          onEdit: () => _openEditEditor(tx),
                          onDelete: () => _confirmDelete(tx),
                        ),
                      ),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditor(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
