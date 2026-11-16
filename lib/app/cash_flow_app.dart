import 'package:flutter/material.dart';

import '../data/cash_flow_data.dart';
import '../navigation/cash_flow_home.dart';

class CashFlowApp extends StatefulWidget {
  const CashFlowApp({super.key});

  @override
  State<CashFlowApp> createState() => _CashFlowAppState();
}

class _CashFlowAppState extends State<CashFlowApp> {
  final CashFlowData _data = CashFlowData();

  @override
  void initState() {
    super.initState();
    _data.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _data,
      builder: (context, _) {
        return MaterialApp(
          title: 'CashFlow',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
            scaffoldBackgroundColor: const Color(0xFFF6F8FC),
          ),
          home: _data.isReady
              ? CashFlowHome(data: _data)
              : const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
        );
      },
    );
  }
}
