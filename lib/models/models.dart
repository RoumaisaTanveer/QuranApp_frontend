// lib/models/models.dart

class AyahMatch {
  final String surah;
  final int ayahNo;
  final String ayah;
  final String ayahAr;
  final int ayahIndex;
  bool isBookmarked;

  AyahMatch({
    required this.surah,
    required this.ayahNo,
    required this.ayah,
    required this.ayahAr,
    required this.ayahIndex,
    this.isBookmarked = false,
  });

  factory AyahMatch.fromJson(Map<String, dynamic> json) => AyahMatch(
        surah: json['surah'] ?? '',
        ayahNo: json['ayah_no'] ?? 0,
        ayah: json['ayah'] ?? '',
        ayahAr: json['ayah_ar'] ?? '',
        ayahIndex: json['ayah_index'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'surah': surah,
        'ayah_no': ayahNo,
        'ayah': ayah,
        'ayah_ar': ayahAr,
        'ayah_index': ayahIndex,
      };
}

class MatchResponse {
  final List<AyahMatch> matches;
  final String comfort;
  final String emotionBefore;
  final int entryId;

  MatchResponse({
    required this.matches,
    required this.comfort,
    required this.emotionBefore,
    required this.entryId,
  });

  factory MatchResponse.fromJson(Map<String, dynamic> json) => MatchResponse(
        matches: (json['matches'] as List)
            .map((m) => AyahMatch.fromJson(m))
            .toList(),
        comfort: json['comfort'] ?? '',
        emotionBefore: json['emotion_before'] ?? '',
        entryId: json['entry_id'] ?? 0,
      );
}

class HistoryItem {
  final int id;
  final String entry;
  final String emotionBefore;
  final String? emotionAfter;
  final String comfort;
  final List<AyahMatch> matches;
  final String timestamp;

  HistoryItem({
    required this.id,
    required this.entry,
    required this.emotionBefore,
    this.emotionAfter,
    required this.comfort,
    required this.matches,
    required this.timestamp,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] ?? 0,
        entry: json['entry'] ?? '',
        emotionBefore: json['emotion_before'] ?? '',
        emotionAfter: json['emotion_after'],
        comfort: json['comfort'] ?? '',
        matches: (json['matches'] as List)
            .map((m) => AyahMatch.fromJson(m))
            .toList(),
        timestamp: json['timestamp'] ?? '',
      );
}

class BookmarkItem {
  final int ayahIndex;
  final String surah;
  final int ayahNo;
  final String ayah;
  final String ayahAr;
  final String note;
  final String savedAt;

  BookmarkItem({
    required this.ayahIndex,
    required this.surah,
    required this.ayahNo,
    required this.ayah,
    required this.ayahAr,
    required this.note,
    required this.savedAt,
  });

  factory BookmarkItem.fromJson(Map<String, dynamic> json) => BookmarkItem(
        ayahIndex: json['ayah_index'] ?? 0,
        surah: json['surah'] ?? '',
        ayahNo: json['ayah_no'] ?? 0,
        ayah: json['ayah'] ?? '',
        ayahAr: json['ayah_ar'] ?? '',
        note: json['note'] ?? '',
        savedAt: json['saved_at'] ?? '',
      );
}

// Emotion metadata
class EmotionMeta {
  static const Map<String, Map<String, dynamic>> data = {
    'grateful':    {'color': 0xFFc9a84c, 'category': 'positive', 'emoji': '🤍'},
    'hopeful':     {'color': 0xFF6dbf8a, 'category': 'positive', 'emoji': '💛'},
    'peaceful':    {'color': 0xFF7ec8c8, 'category': 'positive', 'emoji': '🌿'},
    'happy':       {'color': 0xFFe8c97a, 'category': 'positive', 'emoji': '💛'},
    'content':     {'color': 0xFFa8c87e, 'category': 'positive', 'emoji': '🌙'},
    'reflective':  {'color': 0xFF7098c9, 'category': 'neutral',  'emoji': '🌙'},
    'confused':    {'color': 0xFF9070c9, 'category': 'neutral',  'emoji': '🌙'},
    'anxious':     {'color': 0xFFc98870, 'category': 'negative', 'emoji': '🤍'},
    'stressed':    {'color': 0xFFc97070, 'category': 'negative', 'emoji': '🌿'},
    'sad':         {'color': 0xFF8898c9, 'category': 'negative', 'emoji': '💛'},
    'lonely':      {'color': 0xFFa870c9, 'category': 'negative', 'emoji': '🤍'},
    'heartbroken': {'color': 0xFFc9708a, 'category': 'negative', 'emoji': '🌙'},
    'angry':       {'color': 0xFFc96060, 'category': 'negative', 'emoji': '🌿'},
    'tired':       {'color': 0xFF9888a0, 'category': 'negative', 'emoji': '🤍'},
  };

  static int getColor(String emotion) =>
      data[emotion]?['color'] ?? 0xFF8a8070;

  static String getCategory(String emotion) =>
      data[emotion]?['category'] ?? 'neutral';

  static String getEmoji(String emotion) =>
      data[emotion]?['emoji'] ?? '✦';
}

class WeeklyPattern {
  final int totalEntries;
  final Map<String, int> emotionFrequency;
  final String dominantEmotion;
  final int shiftToPositive;
  final String mostShownSurah;

  WeeklyPattern({
    required this.totalEntries,
    required this.emotionFrequency,
    required this.dominantEmotion,
    required this.shiftToPositive,
    required this.mostShownSurah,
  });

  factory WeeklyPattern.fromJson(Map<String, dynamic> json) {
    final freq = <String, int>{};
    final raw = json['emotion_frequency'];
    if (raw is Map) {
      raw.forEach((k, v) => freq[k.toString()] = (v as num).toInt());
    }
    return WeeklyPattern(
      totalEntries: json['total_entries'] ?? 0,
      emotionFrequency: freq,
      dominantEmotion: json['dominant_emotion'] ?? '—',
      shiftToPositive: json['shift_to_positive'] ?? 0,
      mostShownSurah: json['most_shown_surah'] ?? '—',
    );
  }
}
