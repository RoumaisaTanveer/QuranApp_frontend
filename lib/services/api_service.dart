// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // In dev: set API_BASE_URL via --dart-define=API_BASE_URL=http://10.0.2.2:8000
  // In prod: set to your deployed backend URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000', // Android emulator → host machine
  );

  // Timeout: generous because Render free tier can cold-start in 30-50s
  static const _timeout = Duration(seconds: 60);

  static Future<MatchResponse> matchAyahs(String entry, {int topN = 3}) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/match-ayahs'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'entry': entry, 'top_n': topN}),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return MatchResponse.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    throw Exception('Failed to match ayahs: ${res.statusCode}');
  }

  static Future<void> updateEmotion(int entryId, String emotionAfter) async {
    await http
        .post(
          Uri.parse('$baseUrl/update-emotion'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'entry_id': entryId, 'emotion_after': emotionAfter}),
        )
        .timeout(_timeout);
  }

  static Future<List<HistoryItem>> getHistory() async {
    final res = await http
        .get(Uri.parse('$baseUrl/history'))
        .timeout(_timeout);
    if (res.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(res.bodyBytes));
      return data.map((e) => HistoryItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load history');
  }

  static Future<void> deleteEntry(int entryId) async {
    await http
        .delete(Uri.parse('$baseUrl/delete-entry/$entryId'))
        .timeout(_timeout);
  }

  static Future<BookmarkItem> addBookmark(int ayahIndex, {String note = ''}) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/bookmark'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'ayah_index': ayahIndex, 'note': note}),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return BookmarkItem.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to bookmark');
  }

  static Future<List<BookmarkItem>> getBookmarks() async {
    final res = await http
        .get(Uri.parse('$baseUrl/bookmarks'))
        .timeout(_timeout);
    if (res.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(res.bodyBytes));
      return data.map((e) => BookmarkItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load bookmarks');
  }

  static Future<void> submitFeedback({
    required int entryId,
    required int ayahIndex,
    required int rating,
  }) async {
    await http
        .post(
          Uri.parse('$baseUrl/feedback'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'entry_id': entryId,
            'ayah_index': ayahIndex,
            'rating': rating,
          }),
        )
        .timeout(_timeout);
  }

  static Future<void> removeBookmark(int ayahIndex) async {
    await http
        .delete(Uri.parse('$baseUrl/bookmark/$ayahIndex'))
        .timeout(_timeout);
  }

  static Future<Map<String, dynamic>> getPattern() async {
    final res = await http
        .get(Uri.parse('$baseUrl/pattern'))
        .timeout(_timeout);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('No history yet');
  }

  static Future<MatchResponse> reflectAgain(int entryId) async {
    final res = await http
        .post(Uri.parse('$baseUrl/reflect-again/$entryId'))
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return MatchResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to reflect again');
  }
}
