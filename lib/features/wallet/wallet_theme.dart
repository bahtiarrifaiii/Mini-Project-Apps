import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/wallet.dart';

const walletThemeColors = [
  Color(0xFFF9D365),
  Color(0xFF9FC3F4),
  Color(0xFFB7D58A),
  Color(0xFFEFB3D4),
  Color(0xFFC1B2F2),
  Color(0xFFF2BD83),
  Color(0xFF8FDFC0),
  Color(0xFFEEA3A3),
];

Color walletColor(Wallet wallet) => Color(wallet.themeColor);

Color walletTextColor(Wallet wallet) => wallet.themeImageBase64 != null
    ? Colors.white
    : walletColor(wallet).computeLuminance() > 0.45
    ? const Color(0xFF202020)
    : Colors.white;

DecorationImage? walletThemeDecorationImage(String? imageBase64) {
  if (imageBase64 == null) return null;
  try {
    return DecorationImage(
      image: MemoryImage(base64Decode(imageBase64)),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withValues(alpha: 0.28),
        BlendMode.darken,
      ),
    );
  } on FormatException {
    return null;
  }
}

class WalletBrandMark extends StatelessWidget {
  final double size;

  const WalletBrandMark({super.key, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/icons/cashflow.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
