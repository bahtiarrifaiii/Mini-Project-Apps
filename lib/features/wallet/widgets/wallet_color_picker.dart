import 'package:flutter/material.dart';

import '../wallet_theme.dart';

class WalletColorPicker extends StatelessWidget {
  final int selectedThemeColor;
  final bool isCustomImageActive;
  final ValueChanged<int> onColorSelected;

  const WalletColorPicker({
    super.key,
    required this.selectedThemeColor,
    required this.isCustomImageActive,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: walletThemeColors.asMap().entries.map((entry) {
        final color = entry.value;
        final isSelected =
            !isCustomImageActive && color.toARGB32() == selectedThemeColor;
        return Semantics(
          label: 'Pilihan tema ${entry.key + 1}',
          selected: isSelected,
          button: true,
          child: InkWell(
            onTap: () => onColorSelected(color.toARGB32()),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF202020),
                      size: 23,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
