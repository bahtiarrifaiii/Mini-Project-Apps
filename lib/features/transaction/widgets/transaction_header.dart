import 'package:flutter/material.dart';

class TransactionHeader extends StatelessWidget {
  const TransactionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaksi',
          style: TextStyle(
            fontSize: 25,
            letterSpacing: -0.7,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Pantau seluruh pemasukan dan pengeluaranmu',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
