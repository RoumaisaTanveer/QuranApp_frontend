// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Change this to your deployed backend URL when you deploy
  static const String baseUrl = 'http://localhost:8000';

  static Future<MatchResponse> matchAyahs(String entry, {int topN = 3}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/match-ayahs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'entry': entry, 'top_n': topN}),
    );
    if (res.statusCode == 200) {
      return MatchResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to match ayahs: ${res.statusCode}');
  }

  static Future<void> updateEmotion(int entryId, String emotionAfter) async {
    await http.post(
      Uri.parse('$baseUrl/update-emotion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'entry_id': entryId, 'emotion_after': emotionAfter}),
    );
  }

  static Future<List<HistoryItem>> getHistory() async {
    final res = await http.get(Uri.parse('$baseUrl/history'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(res.bodyBytes));
      return data.map((e) => HistoryItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load history');
  }

  static Future<void> deleteEntry(int entryId) async {
    await http.delete(Uri.parse('$baseUrl/delete-entry/$entryId'));
  }

  static Future<BookmarkItem> addBookmark(int ayahIndex, {String note = ''}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/bookmark'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ayah_index': ayahIndex, 'note': note}),
    );
    if (res.statusCode == 200) {
      return BookmarkItem.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to bookmark');
  }

  static Future<List<BookmarkItem>> getBookmarks() async {
    final res = await http.get(Uri.parse('$baseUrl/bookmarks'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(res.bodyBytes));
      return data.map((e) => BookmarkItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load bookmarks');
  }
  // Add this method to your ApiService class in lib/services/api_service.dart

  static Future<void> submitFeedback({
    required int entryId,
    required int ayahIndex,
    required int rating,
  }) async {
   await http.post(
     Uri.parse('$baseUrl/feedback'),
     headers: {'Content-Type': 'application/json'},
     body: jsonEncode({
       'entry_id': entryId,
       'ayah_index': ayahIndex,
       'rating': rating,
     }),
   );
  }
  static Future<void> removeBookmark(int ayahIndex) async {
    await http.delete(Uri.parse('$baseUrl/bookmark/$ayahIndex'));
  }

  static Future<Map<String, dynamic>> getPattern() async {
    final res = await http.get(Uri.parse('$baseUrl/pattern'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('No history yet');
  }

  static Future<MatchResponse> reflectAgain(int entryId) async {
    final res = await http.post(Uri.parse('$baseUrl/reflect-again/$entryId'));
    if (res.statusCode == 200) {
      return MatchResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to reflect again');
  }
}