import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../models/wallet.dart';
import '../../wallet/wallet_theme.dart';

class WalletCarousel extends StatelessWidget {
  final List<Wallet> wallets;
  final double Function(Wallet) getWalletBalance;
  final PageController pageController;
  final int activeWalletIndex;
  final bool hideBalance;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<Wallet> onEditWallet;
  final VoidCallback onToggleHideBalance;
  final ValueChanged<Wallet> onSeeDetail;
  final VoidCallback onAddWallet;

  const WalletCarousel({
    super.key,
    required this.wallets,
    required this.getWalletBalance,
    required this.pageController,
    required this.activeWalletIndex,
    required this.hideBalance,
    required this.onPageChanged,
    required this.onEditWallet,
    required this.onToggleHideBalance,
    required this.onSeeDetail,
    required this.onAddWallet,
  });

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return Container(
        height: 190,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF404040)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 38,
                color: Colors.white54,
              ),
              const SizedBox(height: 10),
              const Text(
                'Belum ada wallet.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onAddWallet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Wallet'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: pageController,
            itemCount: wallets.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              final balance = getWalletBalance(wallet);
              final isCurrent = index == activeWalletIndex;
              final themeColor = walletBackgroundColor(wallet);
              final textColor = walletTextColor(wallet);

              return AnimatedPadding(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: isCurrent ? 0 : 7,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(24),
                    image: walletThemeDecorationImage(wallet.themeImageBase64),
                    border: Border.all(
                      color: isCurrent
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      width: isCurrent ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Baris Atas: Brand & Edit / Hide Balance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const WalletBrandMark(size: 34),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 105,
                                ),
                                child: Text(
                                  wallet.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: textColor,
                                ),
                                onPressed: () => onEditWallet(wallet),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  hideBalance
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 18,
                                  color: textColor,
                                ),
                                onPressed: onToggleHideBalance,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Tengah: Saldo Wallet
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          hideBalance ? 'Rp ******' : formatCurrency(balance),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),

                      // Bawah: Tombol "See Detail >>"
                      InkWell(
                        onTap: () => onSeeDetail(wallet),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'See Detail >>',
                                style: TextStyle(
                                  color: textColor.withValues(alpha: 0.78),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (wallets.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(wallets.length, (index) {
              final isCurrent = index == activeWalletIndex;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
