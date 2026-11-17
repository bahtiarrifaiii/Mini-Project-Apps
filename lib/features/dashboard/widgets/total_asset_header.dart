import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';

class TotalAssetHeader extends StatelessWidget {
  final double totalBalance;
  final int walletCount;
  final bool hideBalance;
  final VoidCallback onTap;

  const TotalAssetHeader({
    super.key,
    required this.totalBalance,
    required this.walletCount,
    required this.hideBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Kiri: TOTAL ASSETS > & Nilai Total Saldo
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_rounded,
                      color: Color(0xFFE5A93C),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'TOTAL ASSETS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white60,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Colors.white54,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hideBalance ? 'Rp ******' : formatCurrency(totalBalance),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Kanan: Indikator Jumlah Wallet & Tombol Grid
        Row(
          children: [
            if (walletCount > 0)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF404040)),
                ),
                child: Text(
                  '$walletCount Wallets',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF404040)),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
