import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'results_screen.dart';

const List<String> _allEmotions = [
  'grateful', 'hopeful', 'peaceful', 'happy', 'content',
  'reflective', 'confused', 'anxious', 'stressed', 'sad',
  'lonely', 'heartbroken', 'angry', 'tired',
];

/// Full history entry detail — view matches, set emotion_after, delete, reflect again.
/// Endpoints: PATCH /history/{id}/emotion, DELETE /history/{id}, POST /reflect-again/{id}
class HistoryDetailScreen extends StatefulWidget {
  final HistoryItem item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late HistoryItem _item;
  String? _selectedEmotion;
  bool _emotionSaved = false;
  bool _saving = false;
  bool _reflecting = false;
  Set<int> _bookmarked = {};

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    if (_item.emotionAfter != null) {
      _selectedEmotion = _item.emotionAfter;
      _emotionSaved = true;
    }
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final b = await ApiService.getBookmarks();
      if (mounted) {
        setState(() => _bookmarked = b.map((x) => x.ayahIndex).toSet());
      }
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

  Future<void> _saveEmotion() async {
    if (_selectedEmotion == null) return;
    setState(() => _saving = true);
    try {
      await ApiService.updateEmotion(_item.id, _selectedEmotion!);
      setState(() {
        _emotionSaved = true;
        _item = HistoryItem(
          id: _item.id,
          entry: _item.entry,
          emotionBefore: _item.emotionBefore,
          emotionAfter: _selectedEmotion,
          comfort: _item.comfort,
          matches: _item.matches,
          timestamp: _item.timestamp,
        );
      });
      if (mounted) _snack('Reflection saved');
    } catch (_) {
      if (mounted) _snack('Could not save reflection');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reflectAgain() async {
    setState(() => _reflecting = true);
    try {
      final res = await ApiService.reflectAgain(_item.id);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(entry: _item.entry, response: res),
        ),
      );
    } catch (_) {
      if (mounted) _snack('Could not reflect again');
    } finally {
      if (mounted) setState(() => _reflecting = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.bg3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete entry?',
                style: AppText.sans(size: 18, color: AppColors.text),
              ),
              const SizedBox(height: 8),
              Text(
                'This cannot be undone.',
                style: AppText.sans(
                  size: 14,
                  italic: true,
                  color: AppColors.textDim,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrimaryButton(
                    label: 'Cancel',
                    secondary: true,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: AppText.label(
                          size: 10,
                          color: AppColors.red,
                          spacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiService.deleteEntry(_item.id);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) _snack('Could not delete entry');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppText.sans(size: 13, color: AppColors.text)),
        backgroundColor: AppColors.bg3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 14,
              color: AppColors.text,
            ),
          ),
        ),
        title: Text('Entry', style: AppText.label(size: 12, spacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EmotionPill(_item.emotionBefore, small: true),
                if (_item.emotionAfter != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  EmotionPill(_item.emotionAfter!, small: true),
                ],
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 16),
            Text(
              _item.entry,
              style: AppText.sans(
                size: 15,
                color: AppColors.text,
                height: 1.6,
                italic: true,
              ),
            ).animate().fadeIn(delay: 80.ms),
            const SizedBox(height: 20),
            ComfortCard(_item.comfort).animate().fadeIn(delay: 120.ms),
            const SizedBox(height: 24),
            Text(
              'Matched verses',
              style: AppText.label(size: 11, spacing: 1.5),
            ),
            const SizedBox(height: 12),
            ..._item.matches.asMap().entries.map((e) {
              final ayah = e.value;
              return AyahCard(
                ayah: ayah,
                index: e.key + 1,
                total: _item.matches.length,
                isBookmarked: _bookmarked.contains(ayah.ayahIndex),
                onBookmark: () => _toggleBookmark(ayah),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 160 + e.key * 80),
                  );
            }),
            const SizedBox(height: 8),
            Center(
              child: PrimaryButton(
                label: 'Reflect Again',
                icon: Icons.refresh_rounded,
                secondary: true,
                onPressed: _reflecting ? null : _reflectAgain,
                isLoading: _reflecting,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.borderLight,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_emotionSaved) ...[
              Text(
                'How did this make you feel afterward?',
                style: AppText.sans(size: 16, color: AppColors.text),
              ),
              const SizedBox(height: 6),
              Text(
                'Track how the verses shifted your heart.',
                style: AppText.sans(
                  size: 13,
                  italic: true,
                  color: AppColors.textDim,
                ),
              ),
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
                        horizontal: 14,
                        vertical: 7,
                      ),
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
              ),
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
                ),
              ],
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.green.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.green,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Feeling $_selectedEmotion after reading',
                        style: AppText.sans(
                          size: 13,
                          color: AppColors.textDim,
                          italic: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
