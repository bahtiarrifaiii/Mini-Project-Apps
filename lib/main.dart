import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'widgets/bottom_navbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const CashFlowApp());
}

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

String formatCurrency(num value) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  ).format(value);
}

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy', 'id_ID').format(date);
}

String monthKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

class CashFlowApp extends StatefulWidget {
  const CashFlowApp({super.key});

  @override
  State<CashFlowApp> createState() => _CashFlowAppState();
}

class _CashFlowAppState extends State<CashFlowApp> {
  final CashFlowData _data = CashFlowData();

  @override
  void initState() {
    super.initState();
    _data.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _data,
      builder: (context, _) {
        return MaterialApp(
          title: 'CashFlow',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
            scaffoldBackgroundColor: const Color(0xFFF6F8FC),
          ),
          home: _data.isReady
              ? CashFlowHome(data: _data)
              : const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
        );
      },
    );
  }
}

class CashFlowHome extends StatefulWidget {
  final CashFlowData data;

  const CashFlowHome({super.key, required this.data});

  @override
  State<CashFlowHome> createState() => _CashFlowHomeState();
}

class _CashFlowHomeState extends State<CashFlowHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(data: widget.data),
      WalletScreen(data: widget.data),
      TransactionScreen(data: widget.data),
      BudgetScreen(data: widget.data),
      CategoryScreen(data: widget.data),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: () => _openTransactionEditor(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _openTransactionEditor(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionEditorSheet(data: widget.data),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final CashFlowData data;

  const DashboardScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final income = data.totalIncomeThisMonth();
    final expense = data.totalExpenseThisMonth();
    final balance = data.totalBalance();
    final budget = data.currentBudget();

    return RefreshIndicator(
      onRefresh: () async => data.refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          const Text(
            'CashFlow',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SummaryCard(
                title: 'Total Saldo',
                value: formatCurrency(balance),
                color: Colors.blue,
                icon: Icons.account_balance_wallet_rounded,
              ),
              SummaryCard(
                title: 'Pemasukan',
                value: formatCurrency(income),
                color: Colors.green,
                icon: Icons.trending_up_rounded,
              ),
              SummaryCard(
                title: 'Pengeluaran',
                value: formatCurrency(expense),
                color: Colors.red,
                icon: Icons.trending_down_rounded,
              ),
              SummaryCard(
                title: 'Anggaran',
                value: budget == null
                    ? 'Belum diatur'
                    : formatCurrency(budget.limit),
                color: Colors.orange,
                icon: Icons.savings_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grafik Keuangan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        barGroups: data.chartData(),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final labels = data.chartLabels();
                                if (value.toInt() < 0 ||
                                    value.toInt() >= labels.length) {
                                  return const SizedBox();
                                }
                                return Text(
                                  labels[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...data.wallets.map(
                    (wallet) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(
                              Icons.wallet_rounded,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  formatCurrency(data.walletBalance(wallet)),
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.wallet_rounded),
                  ),
                  title: Text(wallet.name),
                  subtitle: Text(formatCurrency(data.walletBalance(wallet))),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, wallet),
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

  Future<void> _showWalletEditor(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WalletEditorSheet(data: data),
    );
  }
}

class TransactionScreen extends StatefulWidget {
  final CashFlowData data;

  const TransactionScreen({super.key, required this.data});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final transactions = widget.data.searchTransactions(_query);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari transaksi',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, index) {
                final transaction = transactions[index];
                final wallet = widget.data.findWallet(transaction.walletId);
                final category = widget.data.findCategory(
                  transaction.categoryId,
                );

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type.color.withValues(
                      alpha: 0.12,
                    ),
                    child: Icon(
                      transaction.type.icon,
                      color: transaction.type.color,
                    ),
                  ),
                  title: Text(
                    transaction.description.isEmpty
                        ? category?.name ?? 'Transaksi'
                        : transaction.description,
                  ),
                  subtitle: Text(
                    '${wallet?.name ?? '-'} • ${formatDate(transaction.date)}',
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${transaction.type == TransactionType.income ? '+' : '-'}${formatCurrency(transaction.amount)}',
                        style: TextStyle(
                          color: transaction.type.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PopupMenuButton<String>(
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'delete', child: Text('Hapus')),
                        ],
                        onSelected: (_) =>
                            widget.data.deleteTransaction(transaction.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTransactionEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openTransactionEditor(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionEditorSheet(data: widget.data),
    );
  }
}

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

class CategoryScreen extends StatelessWidget {
  final CashFlowData data;

  const CategoryScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CategorySection(
            title: 'Pemasukan',
            categories: data.categoriesByType(TransactionType.income),
          ),
          const SizedBox(height: 16),
          _CategorySection(
            title: 'Pengeluaran',
            categories: data.categoriesByType(TransactionType.expense),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Category> categories;

  const _CategorySection({required this.title, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...categories.map(
              (category) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(category.name)),
                  if (!category.isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {},
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Nominal'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() => _date = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal'),
                  child: Text(formatDate(_date)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _walletId.isEmpty ? null : _walletId,
                isExpanded: true,
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

class WalletEditorSheet extends StatefulWidget {
  final CashFlowData data;

  const WalletEditorSheet({super.key, required this.data});

  @override
  State<WalletEditorSheet> createState() => _WalletEditorSheetState();
}

class _WalletEditorSheetState extends State<WalletEditorSheet> {
  final nameController = TextEditingController();
  final balanceController = TextEditingController(text: '0');

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Wallet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama wallet'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Saldo awal'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final balance = double.tryParse(balanceController.text) ?? 0;
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama wallet tidak boleh kosong.'),
                      ),
                    );
                    return;
                  }

                  widget.data.addWallet(
                    Wallet(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      initialBalance: balance,
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
    );
  }
}

class Wallet {
  final String id;
  final String name;
  final double initialBalance;

  Wallet({required this.id, required this.name, required this.initialBalance});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initialBalance': initialBalance,
  };

  factory Wallet.fromJson(Map<String, dynamic> map) => Wallet(
    id: map['id'] ?? '',
    name: map['name'] ?? 'Wallet',
    initialBalance: (map['initialBalance'] ?? 0).toDouble(),
  );
}

class Category {
  final String id;
  final String name;
  final TransactionType type;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.storageValue,
    'isDefault': isDefault,
  };

  factory Category.fromJson(Map<String, dynamic> map) => Category(
    id: map['id'] ?? '',
    name: map['name'] ?? 'Kategori',
    type: TransactionTypeX.fromString(map['type'] ?? 'expense'),
    isDefault: map['isDefault'] ?? false,
  );
}

class Transaction {
  final String id;
  final String walletId;
  final String categoryId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description;

  const Transaction({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'walletId': walletId,
    'categoryId': categoryId,
    'type': type.storageValue,
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory Transaction.fromJson(Map<String, dynamic> map) => Transaction(
    id: map['id'] ?? '',
    walletId: map['walletId'] ?? '',
    categoryId: map['categoryId'] ?? '',
    type: TransactionTypeX.fromString(map['type'] ?? 'expense'),
    amount: (map['amount'] ?? 0).toDouble(),
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    description: map['description'] ?? '',
  );
}

class BudgetSetting {
  final String monthKeyValue;
  final double limit;

  const BudgetSetting({required this.monthKeyValue, required this.limit});

  Map<String, dynamic> toJson() => {
    'monthKeyValue': monthKeyValue,
    'limit': limit,
  };

  factory BudgetSetting.fromJson(Map<String, dynamic> map) => BudgetSetting(
    monthKeyValue: map['monthKeyValue'] ?? monthKey(DateTime.now()),
    limit: (map['limit'] ?? 0).toDouble(),
  );
}

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

  List<BarChartGroupData> chartData() {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);
    final labels = <String>[];
    final values = <BarChartGroupData>[];

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(month.year, month.month - i, 1);
      labels.add(DateFormat('MMM', 'id_ID').format(date));
      final income = transactions
          .where(
            (item) =>
                item.type == TransactionType.income &&
                item.date.year == date.year &&
                item.date.month == date.month,
          )
          .fold<double>(0, (sum, item) => sum + item.amount);
      final expense = transactions
          .where(
            (item) =>
                item.type == TransactionType.expense &&
                item.date.year == date.year &&
                item.date.month == date.month,
          )
          .fold<double>(0, (sum, item) => sum + item.amount);

      values.add(
        BarChartGroupData(
          x: 5 - i,
          barRods: [
            BarChartRodData(toY: income, color: Colors.green, width: 6),
            BarChartRodData(toY: expense, color: Colors.red, width: 6),
          ],
        ),
      );
    }

    return values;
  }

  List<String> chartLabels() {
    final now = DateTime.now();
    final labels = <String>[];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      labels.add(DateFormat('MMM', 'id_ID').format(date));
    }
    return labels;
  }
}
