import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/enums/transaction_type.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/cash_flow_data.dart';
import '../../models/transaction.dart';
import 'transaction_editor_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(now);
    final categories = data.categories
        .where((category) =>
            _typeFilter == null || category.type == _typeFilter)
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
        matchesTime = item.date.year == now.year && item.date.month == now.month;
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
    final dayKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearch(),
            _buildTypeFilters(),
            _buildTimeFilter(monthLabel),
            _buildCategoryFilter(categories),
            _buildSummary(transactions.length, income, expense),
            if (transactions.isEmpty)
              _buildEmptyState()
            else
              ...dayKeys.map((key) => _buildDayGroup(key, grouped[key]!)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditor(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Cari transaksi',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: const Color(0xFF202124),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: .12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: .12)),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilters() {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _typeChip('Semua', null),
          const SizedBox(width: 8),
          _typeChip('Pemasukan', TransactionType.income),
          const SizedBox(width: 8),
          _typeChip('Pengeluaran', TransactionType.expense),
        ],
      ),
    );
  }

  Widget _typeChip(String label, TransactionType? type) {
    final selected = _typeFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _typeFilter = type;
          _categoryFilter = null;
        });
      },
    );
  }

  Widget _buildTimeFilter(String monthLabel) {
    final label = _timeFilter == 'month'
        ? 'Bulan ini ($monthLabel)'
        : _timeFilter == 'range'
            ? 'Pilih rentang waktu'
            : 'Semua bulan';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter waktu',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _timeFilter = value;
                if (value != 'range') _selectedRange = null;
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Semua bulan')),
              PopupMenuItem(value: 'month', child: Text('Bulan ini')),
              PopupMenuItem(
                value: 'range',
                child: Text('Pilih rentang waktu...'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF202124),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 19),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(label,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
          if (_timeFilter == 'range') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _rangeDateField(
                    label: 'Dari',
                    date: _selectedRange?.start,
                    onTap: () => _pickRangeDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _rangeDateField(
                    label: 'Sampai',
                    date: _selectedRange?.end,
                    onTap: () => _pickRangeDate(isStart: false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _rangeDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white60)),
        const SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF202124),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date == null
                        ? 'Pilih tanggal'
                        : DateFormat('d MMM yyyy', 'id_ID').format(date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickRangeDate({required bool isStart}) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final currentStart = _selectedRange?.start;
    final currentEnd = _selectedRange?.end;
    final initial = isStart
        ? (currentStart ?? currentEnd ?? today)
        : (currentEnd ?? currentStart ?? today);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(today) ? today : initial,
      firstDate: DateTime(2000),
      lastDate: today,
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal akhir',
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        final end = currentEnd != null && currentEnd.isBefore(picked)
            ? picked
            : currentEnd ?? picked;
        _selectedRange = DateTimeRange(start: picked, end: end);
      } else {
        final start = currentStart ?? picked;
        if (picked.isBefore(start)) {
          _selectedRange = DateTimeRange(start: picked, end: start);
        } else {
          _selectedRange = DateTimeRange(start: start, end: picked);
        }
      }
    });
  }

  Widget _buildCategoryFilter(List categories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter kategori',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _categoryChip('Semua kategori', null),
                ...categories.map((category) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _categoryChip(category.name, category.id),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String? id) {
    return ChoiceChip(
      label: Text(label),
      selected: _categoryFilter == id,
      onSelected: (_) => setState(() => _categoryFilter = id),
    );
  }

  Widget _buildSummary(int count, double income, double expense) {
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
                'Pemasukan', '+${formatCurrency(income)}', const Color(0xFF55C98A)),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryItem(
                'Pengeluaran', '-${formatCurrency(expense)}', const Color(0xFFFF7777)),
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
          Text(title,
              style: const TextStyle(fontSize: 10, color: Colors.white54)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDayGroup(String key, List<Transaction> items) {
    final date = DateTime.parse(key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            _dayLabel(date),
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),
          ),
        ),
        ...items.map(_buildTransactionCard),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final wallet = data.findWallet(transaction.walletId);
    final category = data.findCategory(transaction.categoryId);
    final isIncome = transaction.type == TransactionType.income;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      color: const Color(0xFF202124),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: transaction.type.color.withValues(alpha: .15),
              child: Icon(transaction.type.icon, color: transaction.type.color),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.description.trim().isEmpty
                        ? category?.name ?? 'Transaksi'
                        : transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category?.name ?? 'Tanpa kategori'} · ${wallet?.name ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(formatDate(transaction.date),
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${formatCurrency(transaction.amount)}',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: isIncome
                        ? const Color(0xFF55C98A)
                        : const Color(0xFFFF7777),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Kelola transaksi',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 120),
                  iconSize: 20,
                  onSelected: (value) {
                    if (value == 'edit') _openEditEditor(transaction);
                    if (value == 'delete') _confirmDelete(transaction);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline, size: 18),
                        SizedBox(width: 8),
                        Text('Hapus'),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 54, color: Colors.white.withValues(alpha: .35)),
          const SizedBox(height: 12),
          const Text('Belum ada transaksi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Coba ubah filter atau tambahkan transaksi baru.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
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
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EditTransactionSheet(
        data: data,
        transaction: transaction,
      ),
    );

    // Notify setelah bottom sheet benar-benar ditutup. Ini menghindari
    // rebuild dependents ketika subtree sheet masih sedang dilepas.
    if (updated == true && mounted) {
      await data.refresh();
      if (mounted) setState(() {});
    }
  }
}

class _EditTransactionSheet extends StatefulWidget {
  final CashFlowData data;
  final Transaction transaction;

  const _EditTransactionSheet({
    required this.data,
    required this.transaction,
  });

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
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
            const Text('Edit Transaksi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                    value: TransactionType.income, label: Text('Pemasukan')),
                ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Pengeluaran')),
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
                  labelText: 'Nominal', prefixText: 'Rp '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: widget.data.wallets.any((w) => w.id == _walletId)
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
              value: _categoryId.isEmpty ? null : _categoryId,
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
