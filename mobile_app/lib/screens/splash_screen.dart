import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'auth_screen.dart';
import '../services/session_service.dart';
import 'home_shell.dart';
import '../widgets/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(seconds: 2));
    final session = await _sessionService.loadSession();

    if (!mounted) {
      return;
    }

    if (session != null && session.token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeShell(role: session.role)),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B57).withOpacity(0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 124,
                      height: 124,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 124,
                        height: 124,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B57),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.attractions_rounded, color: Colors.white, size: 56),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 550.ms, curve: Curves.easeOutBack).fadeIn(),
                const SizedBox(height: 24),
                Text(
                  'Ride Guide',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08),
                const SizedBox(height: 10),
                Text(
                  'Discover rides, check queues, and explore the park with confidence.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                        color: Colors.black.withOpacity(0.72),
                      ),
                ).animate().fadeIn(delay: 280.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
