import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onAddPressed;

  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Background gelap seperti screenshot
        border: Border(
          top: BorderSide(
            color: Color(0xFF404040),
            width: 1,
          ), // Garis tipis atas
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Menu Home (Tetap mengarah ke index 0)
              _buildNavItem(
                label: 'Home',
                icon: CupertinoIcons.house,
                activeIcon: CupertinoIcons.house_fill,
                isSelected: selectedIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
              // 2. Tombol Tambah (+) di tengah
              _buildAddButton(),
              // 3. Menu Transactions (Tetap mengarah ke index 2)
              _buildNavItem(
                label: 'Transactions',
                icon: CupertinoIcons.doc_text,
                activeIcon: CupertinoIcons.doc_text_fill,
                isSelected: selectedIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Item Navigasi (Icon + Label Teks)
  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? Colors.white : Colors.white38;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Tombol (+) di tengah
  Widget _buildAddButton() {
    return Expanded(
      child: InkWell(
        onTap: onAddPressed,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size:
                32, // Ukuran tombol plus besar dan jelas seperti di screenshot
          ),
        ),
      ),
    );
  }
}
