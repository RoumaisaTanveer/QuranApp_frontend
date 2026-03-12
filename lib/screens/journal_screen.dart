// lib/screens/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';
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

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiService.matchAyahs(_ctrl.text.trim());
      if (!mounted) return;
      await Navigator.push(context, PageRouteBuilder(
        pageBuilder: (_, a, __) => ResultsScreen(entry: _ctrl.text.trim(), response: res),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ));
      _ctrl.clear();
    } catch (e) {
      setState(() => _error = 'Could not reach server. Is the backend running?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        // Purple glow top right — matches reference orb glow
        Positioned(
          top: -80, right: -80,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.purple.withOpacity(0.12),
                Colors.transparent,
              ]),
            ),
          ),
        ),

        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header — like "Aug 11, 2024" date header in reference
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('مع القرآن',
                    textDirection: TextDirection.rtl,
                    style: AppText.arabic(size: 22, color: AppColors.purple),
                  ),
                  Text('With the Quran',
                    style: AppText.label(size: 12, color: AppColors.textSub),
                  ),
                ]),

                // Purple glowing avatar — matches the reference orb
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.purple, Color(0xFF5B3CC4)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purpleGlow,
                        blurRadius: 20, spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 20),
                ),
              ]).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 28),

              // Journal card
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _focus.hasFocus
                        ? AppColors.purple.withOpacity(0.5)
                        : AppColors.border,
                  ),
                  boxShadow: _focus.hasFocus ? [
                    BoxShadow(color: AppColors.purpleGlow, blurRadius: 20, spreadRadius: -4),
                  ] : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(children: [
                        Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.purple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("Today's Reflection",
                          style: AppText.sans(size: 13, color: AppColors.textSub, weight: FontWeight.w500),
                        ),
                      ]),
                    ),
                    TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      maxLines: 7, minLines: 5,
                      onChanged: (_) => setState(() {}),
                      style: AppText.sans(size: 15, color: AppColors.text, height: 1.7),
                      cursorColor: AppColors.purple,
                      decoration: InputDecoration(
                        hintText: 'Write whatever is on your heart...',
                        hintStyle: AppText.sans(
                          size: 15, color: AppColors.textMuted, height: 1.7,
                        ).copyWith(fontStyle: FontStyle.italic),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      ),
                    ),
                    // Bottom of card — char count + button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 14, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_ctrl.text.length} chars',
                            style: AppText.label(size: 10, color: AppColors.textMuted),
                          ),
                          _loading
                            ? const SizedBox(
                                height: 36,
                                child: Center(child: LoadingDots()),
                              )
                            : PrimaryButton(
                                label: 'Seek Guidance',
                                icon: Icons.auto_awesome_rounded,
                                onPressed: _ctrl.text.trim().isEmpty ? null : _submit,
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),

              // Error
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.red.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, size: 15, color: AppColors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error,
                      style: AppText.label(size: 12, color: AppColors.red))),
                  ]),
                ),
              ],

              const SizedBox(height: 24),

              // Quick emotion selector — like the "Goal / Task" tabs in reference
              Text('How are you feeling?',
                style: AppText.sans(size: 13, color: AppColors.textSub, weight: FontWeight.w500),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  'stressed','sad','anxious','lonely','grateful',
                  'hopeful','peaceful','angry','tired','confused',
                ].map((e) => GestureDetector(
                  onTap: () {
                    _ctrl.text = 'I am feeling $e today';
                    _ctrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: _ctrl.text.length));
                    setState(() {});
                  },
                  child: EmotionPill(e, small: true),
                )).toList(),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              // Ayah of the day — like a "connect your calendar" card in reference
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.purpleDim,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.format_quote_rounded,
                        size: 16, color: AppColors.purple),
                    ),
                    const SizedBox(width: 10),
                    Text('Verse of the Day',
                      style: AppText.sans(size: 13, weight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 14),
                  Text(
                    'أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: AppText.arabic(size: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"Verily, in the remembrance of Allah do hearts find rest."',
                    textAlign: TextAlign.center,
                    style: AppText.sans(size: 13, color: AppColors.textSub, height: 1.6)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.purpleDim,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text("Ar-Ra'd · 28",
                      style: AppText.label(size: 10, color: AppColors.purple),
                    ),
                  ),
                ]),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 20),
            ],
          ),
        )),
      ]),
    );
  }
}