import 'package:flutter/material.dart';
import 'screens/calc_screen.dart';

void main() {
  runApp(const MedCalcApp());
}

class MedCalcApp extends StatelessWidget {
  const MedCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '鹦鹉药物计算器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const CalcScreen(),
    );
  }
}
