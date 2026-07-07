import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'main_shell.dart';

/// Google-only sign-in screen.
/// Endpoint: POST /auth/google
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String _error = '';

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on AuthException catch (e) {
      if (e.message != 'Sign in cancelled.') {
        setState(() => _error = e.message);
      }
    } catch (e) {
      setState(() => _error = 'Sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purple.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'انس',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppText.arabic(size: 42, color: AppColors.goldLight),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    'مع القرآن',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppText.arabic(size: 18, color: AppColors.textSub),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 12),
                  Text(
                    'Your personal Quranic journal',
                    textAlign: TextAlign.center,
                    style: AppText.sans(
                      size: 13,
                      color: AppColors.textDim,
                      italic: true,
                    ),
                  ).animate().fadeIn(delay: 180.ms),
                  const Spacer(flex: 3),
                  if (_error.isNotEmpty) ...[
                    _ErrorBanner(message: _error),
                    const SizedBox(height: 20),
                  ],
                  _GoogleSignInButton(
                    loading: _loading,
                    onPressed: _signInWithGoogle,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  Text(
                    'Sign in securely with your Google account',
                    textAlign: TextAlign.center,
                    style: AppText.sans(
                      size: 12,
                      color: AppColors.textMuted,
                      italic: true,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppText.arabic(size: 14, color: AppColors.textMuted),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({
    required this.loading,
    required this.onPressed,
  });

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.loading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_pressed ? 0.1 : 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.loading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.purple,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Google',
                      style: AppText.sans(
                        size: 15,
                        color: AppColors.text,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 120),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.red.withOpacity(0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.error_outline_rounded, size: 16, color: AppColors.red),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  message,
                  style: AppText.sans(size: 13, color: AppColors.red),
                ),
              ),
            ),
          ],
        ),
      );
}