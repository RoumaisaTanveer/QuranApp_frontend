// lib/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

const List<String> _allEmotions = [
  'grateful','hopeful','peaceful','happy','content',
  'reflective','confused','anxious','stressed','sad',
  'lonely','heartbroken','angry','tired',
];

class ResultsScreen extends StatefulWidget {
  final String entry;
  final MatchResponse response;
  const ResultsScreen({super.key, required this.entry, required this.response});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Set<int> _bookmarked = {};
  // Maps ayah_index → rating (1 or -1)
  final Map<int, int> _ratings = {};
  String? _selectedEmotion;
  bool _emotionSaved = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final b = await ApiService.getBookmarks();
      setState(() => _bookmarked = b.map((x) => x.ayahIndex).toSet());
    } catch (_) {}
  }

  Future<void> _toggleBookmark(AyahMatch ayah) async {
    final has = _bookmarked.contains(ayah.ayahIndex);
    try {
      if (has) {
        await ApiService.removeBookmark(ayah.ayahIndex);
        setState(() => _bookmarked.remove(ayah.ayahIndex));
        _snack('Bookmark removed');
      } else {
        await ApiService.addBookmark(ayah.ayahIndex);
        setState(() => _bookmarked.add(ayah.ayahIndex));
        _snack('Verse saved ✦');
      }
    } catch (_) {
      _snack('Could not update bookmark');
    }
  }

  Future<void> _rate(AyahMatch ayah, int rating) async {
    // Toggle off if same rating tapped again
    final current = _ratings[ayah.ayahIndex];
    final newRating = current == rating ? null : rating;

    setState(() {
      if (newRating == null) {
        _ratings.remove(ayah.ayahIndex);
      } else {
        _ratings[ayah.ayahIndex] = newRating;
      }
    });

    if (newRating == null) return; // untoggled, no need to send

    try {
      await ApiService.submitFeedback(
        entryId: widget.response.entryId,
        ayahIndex: ayah.ayahIndex,
        rating: newRating,
      );
    } catch (_) {
      // silently fail — rating is still stored locally for UX
    }
  }

  Future<void> _saveEmotion() async {
    if (_selectedEmotion == null) return;
    setState(() => _saving = true);
    try {
      await ApiService.updateEmotion(widget.response.entryId, _selectedEmotion!);
      setState(() => _emotionSaved = true);
    } catch (_) {} finally {
      setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppText.sans(size: 13, color: AppColors.text)),
      backgroundColor: AppColors.bg3,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final emotion = widget.response.emotionBefore;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                size: 14, color: AppColors.text),
          ),
        ),
        title: Text('Ayahs for You',
            style: AppText.label(size: 12, spacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emotion detected chip
            Row(children: [
              Text('Feeling  ',
                  style: AppText.sans(
                      size: 13, color: AppColors.textDim, italic: true)),
              EmotionPill(emotion),
            ]).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 20),

            // Ayah cards with feedback
            ...widget.response.matches.asMap().entries.map((e) {
              final ayah = e.value;
              final rating = _ratings[ayah.ayahIndex];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AyahCard(
                    ayah: ayah,
                    index: e.key + 1,
                    total: widget.response.matches.length,
                    isBookmarked: _bookmarked.contains(ayah.ayahIndex),
                    onBookmark: () => _toggleBookmark(ayah),
                  ),
                  // Feedback row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 16),
                    child: Row(
                      children: [
                        Text(
                          'Was this verse relevant?',
                          style: AppText.sans(
                              size: 11,
                              color: AppColors.textMuted,
                              italic: true),
                        ),
                        const Spacer(),
                        _FeedbackButton(
                          icon: Icons.thumb_up_rounded,
                          active: rating == 1,
                          activeColor: AppColors.green,
                          onTap: () => _rate(ayah, 1),
                        ),
                        const SizedBox(width: 8),
                        _FeedbackButton(
                          icon: Icons.thumb_down_rounded,
                          active: rating == -1,
                          activeColor: AppColors.red,
                          onTap: () => _rate(ayah, -1),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 200 + e.key * 150))
                  .slideY(begin: 0.12, end: 0);
            }),

            const SizedBox(height: 6),

            // Comfort card
            ComfortCard(widget.response.comfort)
                .animate()
                .fadeIn(delay: 650.ms),

            const SizedBox(height: 28),

            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  AppColors.borderLight,
                  Colors.transparent,
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // Emotion after
            if (!_emotionSaved) ...[
              Text(
                'How do you feel after reading?',
                style: AppText.sans(size: 16, color: AppColors.text),
              ).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 6),
              Text(
                'Tracking your emotional shift helps you understand the Quran\'s impact.',
                style: AppText.sans(
                    size: 13, italic: true, color: AppColors.textDim),
              ).animate().fadeIn(delay: 750.ms),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allEmotions.map((e) {
                  final selected = _selectedEmotion == e;
                  final color = Color(EmotionMeta.getColor(e));
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmotion = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withOpacity(0.12)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: selected
                              ? color.withOpacity(0.5)
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        e,
                        style: AppText.label(
                          size: 9,
                          color: selected ? color : AppColors.textMuted,
                          spacing: 0.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 800.ms),

              if (_selectedEmotion != null) ...[
                const SizedBox(height: 20),
                Center(
                  child: PrimaryButton(
                    label: 'Save Reflection',
                    icon: Icons.check_rounded,
                    onPressed: _saveEmotion,
                    isLoading: _saving,
                    secondary: true,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              ],
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.green.withOpacity(0.25)),
                ),
                child: Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: AppColors.green, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reflection saved',
                          style: AppText.label(
                              size: 10,
                              color: AppColors.green,
                              spacing: 1),
                        ),
                        Text(
                          'Feeling $_selectedEmotion after reading',
                          style: AppText.sans(
                              size: 12,
                              color: AppColors.textDim,
                              italic: true),
                        ),
                      ]),
                ]),
              ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }
}

// ── Feedback button widget ─────────────────────────────────────────────────
class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.12) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? activeColor.withOpacity(0.4)
                : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: active ? activeColor : AppColors.textMuted,
        ),
      ),
    );
  }
}