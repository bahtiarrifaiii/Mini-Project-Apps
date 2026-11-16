import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.wallet_rounded),
          label: 'Wallet',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Transaksi',
        ),
      ],
    );
  }
}
