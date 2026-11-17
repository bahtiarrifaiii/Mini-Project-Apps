import 'package:flutter/material.dart';

import '../../../core/enums/transaction_type.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/category.dart';
import '../../../models/transaction.dart';
import '../../../models/wallet.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Wallet? wallet;
  final Category? category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.wallet,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category?.name ?? 'Tanpa kategori'} · ${wallet?.name ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(transaction.date),
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
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
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
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
}
