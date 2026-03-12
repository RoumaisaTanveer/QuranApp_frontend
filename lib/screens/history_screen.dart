// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.initialTab = 0});

  final int initialTab; // 0 = Entries, 1 = Saved Ayahs

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}


class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<HistoryItem> _history = [];
  List<BookmarkItem> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
   super.initState();
  _tab = TabController(length: 2, vsync: this);
  _tab.index = widget.initialTab.clamp(0, 1);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final h = await ApiService.getHistory();
      final b = await ApiService.getBookmarks();
      setState(() { _history = h.reversed.toList(); _bookmarks = b; });
    } catch (_) {} finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteEntry(int reversedIndex) async {
    final originalIndex = _history.length - 1 - reversedIndex;
    try {
      await ApiService.deleteEntry(originalIndex);
      setState(() => _history.removeAt(reversedIndex));
      if (mounted) _snack('Entry deleted');
    } catch (_) {}
  }

  Future<void> _removeBookmark(int ayahIndex, int listIdx) async {
    try {
      await ApiService.removeBookmark(ayahIndex);
      setState(() => _bookmarks.removeAt(listIdx));
    } catch (_) {}
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: AppText.sans(size: 13, color: AppColors.text)),
    backgroundColor: AppColors.bg3,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));

  String _formatDate(String ts) {
    try {
      final dt = DateTime.parse(ts);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month-1]} ${dt.year}';
    } catch (_) { return ts; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('History', style: AppText.label(size: 14, spacing: 2.5)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: AppText.label(size: 10, color: AppColors.bg, spacing: 1),
              unselectedLabelStyle: AppText.label(size: 10, color: AppColors.textMuted, spacing: 1),
              labelColor: AppColors.bg,
              unselectedLabelColor: AppColors.textMuted,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Entries'),
                Tab(text: 'Saved Ayahs'),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: LoadingDots())
          : RefreshIndicator(
              color: AppColors.purple,
              backgroundColor: AppColors.card,
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tab,
                children: [_entriesTab(), _bookmarksTab()],
              ),
            ),
    );
  }

  Widget _entriesTab() {
    if (_history.isEmpty) {
      return const EmptyState(
        arabic: 'اكتب',
        message: 'No entries yet.\nWrite your first reflection.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: _history.length,
      itemBuilder: (_, i) => _EntryCard(
        item: _history[i],
        date: _formatDate(_history[i].timestamp),
        onDelete: () => _showDeleteDialog(i),
      ).animate().fadeIn(delay: Duration(milliseconds: i * 50)),
    );
  }

  Widget _bookmarksTab() {
    if (_bookmarks.isEmpty) {
      return const EmptyState(
        arabic: 'نجمة',
        message: 'No saved verses yet.\nTap the bookmark icon on any verse.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: _bookmarks.length,
      itemBuilder: (_, i) {
        final bm = _bookmarks[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: Text(bm.ayahAr,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppText.arabic(size: 20, color: AppColors.purpleLight),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(bm.ayah,
                  style: AppText.sans(size: 14, italic: true, color: AppColors.text),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.auto_stories_rounded, size: 12, color: AppColors.purple),
                      const SizedBox(width: 6),
                      Text('${bm.surah} · ${bm.ayahNo}',
                        style: AppText.label(size: 9, color: AppColors.purple, spacing: 0.5),
                      ),
                    ]),
                    GestureDetector(
                      onTap: () => _removeBookmark(bm.ayahIndex, i),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bookmark_remove_rounded,
                          size: 15, color: AppColors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 50));
      },
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
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
              Text('Delete entry?', style: AppText.sans(size: 18, color: AppColors.text)),
              const SizedBox(height: 8),
              Text('This cannot be undone.',
                style: AppText.sans(size: 14, italic: true, color: AppColors.textDim),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrimaryButton(label: 'Cancel', secondary: true,
                    onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () { Navigator.pop(context); _deleteEntry(index); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.red.withOpacity(0.3)),
                      ),
                      child: Text('Delete',
                        style: AppText.label(size: 10, color: AppColors.red, spacing: 1),
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
  }
}

class _EntryCard extends StatelessWidget {
  final HistoryItem item;
  final String date;
  final VoidCallback onDelete;
  const _EntryCard({required this.item, required this.date, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final afterCat = item.emotionAfter != null
        ? EmotionMeta.getCategory(item.emotionAfter!) : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date,
                      style: AppText.label(size: 9, color: AppColors.textMuted, spacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.entry.length > 110
                          ? '${item.entry.substring(0, 110)}...' : item.entry,
                      style: AppText.sans(size: 14, color: AppColors.textDim, italic: true),
                    ),
                  ],
                )),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                      size: 15, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 1,
            color: AppColors.border,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(children: [
              EmotionPill(item.emotionBefore, small: true),
              if (item.emotionAfter != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 12,
                    color: afterCat == 'positive' ? AppColors.green
                        : afterCat == 'negative' ? AppColors.red
                        : AppColors.textMuted,
                  ),
                ),
                EmotionPill(item.emotionAfter!, small: true),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}