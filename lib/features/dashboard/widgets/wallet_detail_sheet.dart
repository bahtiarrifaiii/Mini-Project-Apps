import 'package:flutter/material.dart';

import '../../../core/enums/transaction_type.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/transaction.dart';
import '../../../models/wallet.dart';

class WalletDetailSheet extends StatelessWidget {
  final Wallet wallet;
  final double balance;
  final List<Transaction> transactions;

  const WalletDetailSheet({
    super.key,
    required this.wallet,
    required this.balance,
    required this.transactions,
  });

  static Future<void> show(
    BuildContext context, {
    required Wallet wallet,
    required double balance,
    required List<Transaction> transactions,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => WalletDetailSheet(
        wallet: wallet,
        balance: balance,
        transactions: transactions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(18),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      formatCurrency(balance),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada transaksi di wallet ini.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      itemCount: transactions.length,
                      separatorBuilder: (_, _) =>
                          const Divider(color: Color(0xFF404040)),
                      itemBuilder: (context, i) {
                        final tx = transactions[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                tx.type.color.withValues(alpha: 0.15),
                            child: Icon(
                              tx.type.icon,
                              color: tx.type.color,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            tx.description.isEmpty
                                ? 'Transaksi'
                                : tx.description,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            formatDate(tx.date),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            '${tx.type == TransactionType.income ? '+' : '-'}${formatCurrency(tx.amount)}',
                            style: TextStyle(
                              color: tx.type.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
