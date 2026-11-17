import 'package:flutter/material.dart';

import '../../core/enums/transaction_type.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/cash_flow_data.dart';
import 'transaction_editor_sheet.dart';

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
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                hintText: 'Cari transaksi',
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, _) => const Divider(color: Color(0xFF404040)),
              itemBuilder: (_, index) {
                final transaction = transactions[index];
                final wallet = widget.data.findWallet(transaction.walletId);
                final category = widget.data.findCategory(
                  transaction.categoryId,
                );

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type.color.withValues(
                      alpha: 0.15,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${wallet?.name ?? '-'} • ${formatDate(transaction.date)}',
                    style: const TextStyle(color: Colors.white70),
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
