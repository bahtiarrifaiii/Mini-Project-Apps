import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../data/cash_flow_data.dart';
import '../../../models/wallet.dart';
import '../../wallet/wallet_theme.dart';

class SelectAssetSheet extends StatelessWidget {
  final CashFlowData data;
  final int activeWalletIndex;
  final ValueChanged<int> onSelectWallet;
  final VoidCallback onAddWallet;
  final Future<void> Function(Wallet) onEditWallet;
  final Future<void> Function(Wallet) onDeleteWallet;

  const SelectAssetSheet({
    super.key,
    required this.data,
    required this.activeWalletIndex,
    required this.onSelectWallet,
    required this.onAddWallet,
    required this.onEditWallet,
    required this.onDeleteWallet,
  });

  static Future<void> show(
    BuildContext context, {
    required CashFlowData data,
    required int activeWalletIndex,
    required ValueChanged<int> onSelectWallet,
    required VoidCallback onAddWallet,
    required Future<void> Function(Wallet) onEditWallet,
    required Future<void> Function(Wallet) onDeleteWallet,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SelectAssetSheet(
        data: data,
        activeWalletIndex: activeWalletIndex,
        onSelectWallet: onSelectWallet,
        onAddWallet: onAddWallet,
        onEditWallet: onEditWallet,
        onDeleteWallet: onDeleteWallet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        final totalBalance = data.totalBalance();

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar
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

                // Judul Sheet
                const Center(
                  child: Text(
                    'Select Asset',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Banner Total Assets & Tombol + Add Asset
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF404040)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL ASSETS',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(totalBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDE749B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          onAddWallet();
                          setSheetState(() {});
                        },
                        icon: const Icon(Icons.add, size: 17),
                        label: const Text(
                          '+ Add Asset',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Header REGULAR WALLETS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'REGULAR WALLETS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white60,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      formatCurrency(totalBalance),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Grid Daftar Wallet
                if (data.wallets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'Belum ada wallet. Tekan "+ Add Asset" untuk menambah.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: data.wallets.length,
                      itemBuilder: (context, index) {
                        final wallet = data.wallets[index];
                        final isSelected = index == activeWalletIndex;
                        final balance = data.walletBalance(wallet);
                        final textColor = walletTextColor(wallet);

                        return InkWell(
                          onTap: () {
                            onSelectWallet(index);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: walletBackgroundColor(wallet),
                              borderRadius: BorderRadius.circular(18),
                              image: walletThemeDecorationImage(
                                wallet.themeImageBase64,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.35),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const WalletBrandMark(size: 34),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: textColor,
                                        size: 20,
                                      ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wallet.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatCurrency(balance),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: textColor,
                                      ),
                                      onPressed: () async {
                                        await onEditWallet(wallet);
                                        setSheetState(() {});
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: textColor,
                                      ),
                                      onPressed: () async {
                                        await onDeleteWallet(wallet);
                                        setSheetState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ],
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
      },
    );
  }
}
