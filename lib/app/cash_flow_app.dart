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
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF404040), width: 1),
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF404040), width: 1),
              ),
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                side: BorderSide(color: Color(0xFF404040), width: 1),
              ),
            ),
            dividerTheme: const DividerThemeData(color: Color(0xFF404040)),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              hintStyle: const TextStyle(color: Colors.white38),
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF404040)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF404040)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 1.5,
                ),
              ),
            ),
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
