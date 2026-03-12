import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;
  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // Show splash for 2.8 seconds then fade to app
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _done
          ? KeyedSubtree(
              key: const ValueKey('app'),
              child: widget.child,
            )
          : const KeyedSubtree(
              key: ValueKey('splash'),
              child: _SplashContent(),
            ),
    );
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
          // Background purple glow
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

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing orb icon – purple only
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.purple,
                        Color(0xFF5B3CC4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purpleGlow,
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
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

                // Arabic title (gold)
                Text(
                  'مع القرآن',
                  textDirection: TextDirection.rtl,
                  style: AppText.arabic(
                    size: 38,
                    color: AppColors.goldLight,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      delay: 500.ms,
                      duration: 600.ms,
                    ),

                const SizedBox(height: 8),

                // English subtitle
                Text(
                  'With the Quran',
                  style: AppText.sans(
                    size: 14,
                    color: AppColors.textSub,
                    weight: FontWeight.w300,
                  ),
                ).animate().fadeIn(
                      delay: 700.ms,
                      duration: 600.ms,
                    ),

                const SizedBox(height: 60),

                // Loading dots – purple
                _PulseDots()
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 400.ms),
              ],
            ),
          ),

          // Bottom tagline
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Text(
              'أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppText.arabic(
                size: 14,
                color: AppColors.textMuted,
              ),
            )
                .animate()
                .fadeIn(
                  delay: 900.ms,
                  duration: 800.ms,
                ),
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
