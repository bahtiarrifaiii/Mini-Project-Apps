import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String formattedToday;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.formattedToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 25,
            letterSpacing: -0.7,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Yuk, pantau kondisi keuanganmu hari ini!',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF404040)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 15,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                formattedToday,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
