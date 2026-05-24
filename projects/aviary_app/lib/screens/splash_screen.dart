import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 500)); // 加载动画
    final auth = AuthService();
    await auth.init();
    if (!mounted) return;
    if (auth.isLoggedIn && auth.sessionCookie != null && auth.sessionCookie!.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
      ).primaryContainer,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🦜', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '鸟舍管理系统',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
