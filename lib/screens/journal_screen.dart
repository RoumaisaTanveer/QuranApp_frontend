// lib/screens/journal_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';
import '../widgets/rotating_ayah_footer.dart';
import 'profile_screen.dart';
import 'results_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _loading = false;
  String _error = '';
  // Tracks elapsed seconds while loading so we can show a reassuring message
  int _loadingSeconds = 0;
  Timer? _loadTimer;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _loadTimer?.cancel();
    super.dispose();
  }

  void _startLoadTimer() {
    _loadingSeconds = 0;
    _loadTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _loadingSeconds++);
    });
  }

  void _stopLoadTimer() {
    _loadTimer?.cancel();
    _loadTimer = null;
    _loadingSeconds = 0;
  }

  String get _loadingHint {
    if (_loadingSeconds < 5)  return 'Finding verses for you...';
    if (_loadingSeconds < 15) return 'Searching the Quran...';
    if (_loadingSeconds < 30) return 'Almost there...';
    return 'Waking the server, please wait...';
  }

  Future<void> _submit() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    _startLoadTimer();
    try {
      final res = await ApiService.matchAyahs(_ctrl.text.trim());
      if (!mounted) return;
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) =>
              ResultsScreen(entry: _ctrl.text.trim(), response: res),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
      _ctrl.clear();
    } on TimeoutException {
      setState(() => _error = 'Request timed out. Check your connection or try again.');
    } catch (e) {
      setState(() => _error = 'Could not reach server. Is the backend running?');
    } finally {
      _stopLoadTimer();
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Top-right purple glow
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مع القرآن',
                            textDirection: TextDirection.rtl,
                            style: AppText.arabic(
                              size: 22,
                              color: AppColors.goldLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'With the Quran',
                            style: AppText.sans(
                              size: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      // Profile + date
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.person_outline_rounded,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              _todayLabel(),
                              style: AppText.label(
                                  size: 10,
                                  color: AppColors.textDim,
                                  spacing: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 32),

                  // Prompt
                  Text(
                    'How are you feeling today?',
                    style: AppText.sans(size: 22, color: AppColors.text),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 6),

                  Text(
                    'Write freely — as little or as much as you need.',
                    style: AppText.sans(
                        size: 13, color: AppColors.textDim, italic: true),
                  ).animate().fadeIn(delay: 180.ms),

                  const SizedBox(height: 20),

                  // Journal text field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _focus.hasFocus
                            ? AppColors.purple.withOpacity(0.5)
                            : AppColors.border,
                      ),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      maxLines: 8,
                      minLines: 5,
                      style: AppText.sans(
                          size: 15, color: AppColors.text, height: 1.6),
                      decoration: InputDecoration(
                        hintText:
                            'Today I feel... / Aaj mujhe lag raha hai...',
                        hintStyle: AppText.sans(
                            size: 14,
                            color: AppColors.textMuted,
                            italic: true),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 6),

                  // Character count
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_ctrl.text.length} chars',
                      style: AppText.label(
                          size: 10, color: AppColors.textMuted, spacing: 0),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Loading hint (only shown while loading)
                  if (_loading)
                    Center(
                      child: Column(
                        children: [
                          const LoadingDots(),
                          const SizedBox(height: 10),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              _loadingHint,
                              key: ValueKey(_loadingSeconds ~/ 5),
                              style: AppText.sans(
                                  size: 13,
                                  color: AppColors.textDim,
                                  italic: true),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn()
                  else
                    Center(
                      child: PrimaryButton(
                        label: 'Find My Verse',
                        icon: Icons.auto_awesome_rounded,
                        onPressed:
                            _ctrl.text.trim().isEmpty ? null : _submit,
                        isLoading: _loading,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                  // Error
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.red.withOpacity(0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 16, color: AppColors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error,
                            style: AppText.sans(
                                size: 13, color: AppColors.red),
                          ),
                        ),
                      ]),
                    ).animate().fadeIn().shakeX(),
                  ],

                  const SizedBox(height: 40),

                  // Quran verse footer (rotates every 8s)
                  const Center(
                    child: RotatingAyahFooter(),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}
