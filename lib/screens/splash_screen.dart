import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../widgets/rotating_ayah_footer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// Splash + auth gate on launch.
/// Endpoints: validates stored token via GET /auth/me
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Minimum branding display time
    await Future.delayed(const Duration(milliseconds: 2200));
    final valid = await AuthService.instance.validateSession();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => valid ? const MainShell() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _SplashContent();
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purple.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.5, 1.5),
                duration: 2800.ms,
                curve: Curves.easeOut,
              ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon/app_icon_foreground.png',
                  width: 160,
                  height: 160,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1.0, 1.0),
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 32),
                Text(
                  'انس',
                  textDirection: TextDirection.rtl,
                  style: AppText.arabic(
                    size: 44,
                    color: AppColors.goldLight,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, delay: 500.ms, duration: 600.ms),
                const SizedBox(height: 10),
                Text(
                  'مع القرآن',
                  textDirection: TextDirection.rtl,
                  style: AppText.arabic(
                    size: 20,
                    color: AppColors.textSub,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 600.ms),
                const SizedBox(height: 60),
                _PulseDots()
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 400.ms),
              ],
            ),
          ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: const RotatingAyahFooter(
              arabicSize: 14,
              englishSize: 10,
            ).animate().fadeIn(delay: 900.ms, duration: 800.ms),
          ),
        ],
      ),
    );
  }
}

class _PulseDots extends StatefulWidget {
  @override
  State<_PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<_PulseDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final o = (((_ctrl.value * 3) - i) % 1 + 1) % 1;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.purple.withOpacity(0.2 + 0.8 * o),
              ),
            );
          }),
        ),
      );
}