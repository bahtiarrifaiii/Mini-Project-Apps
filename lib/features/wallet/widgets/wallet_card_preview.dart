import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../wallet_theme.dart';

class WalletCardPreview extends StatelessWidget {
  final int themeColor;
  final String? themeImageBase64;
  final String walletName;
  final double balance;

  const WalletCardPreview({
    super.key,
    required this.themeColor,
    required this.themeImageBase64,
    required this.walletName,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Color(themeColor);
    final hasImage = themeImageBase64 != null;
    final textColor = hasImage
        ? Colors.white
        : theme.computeLuminance() > 0.45
            ? const Color(0xFF202020)
            : Colors.white;

    return AspectRatio(
      aspectRatio: 1.85,
      child: Container(
        decoration: BoxDecoration(
          color: theme,
          borderRadius: BorderRadius.circular(22),
          image: walletThemeDecorationImage(themeImageBase64),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: theme.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const WalletBrandMark(size: 42),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'WALLET',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    walletName.trim().isEmpty ? 'Nama Wallet' : walletName.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatCurrency(balance),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
