import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/auth_service.dart';
import 'screens/home_task_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AviaryApp());
}

class AviaryApp extends StatelessWidget {
  const AviaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🦜 鸟舍管理系统',
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeTaskScreen(),
      },
    );
  }
}
