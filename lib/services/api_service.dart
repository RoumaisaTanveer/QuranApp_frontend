// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'auth_service.dart';

class ApiService {
  // In dev: set API_BASE_URL via --dart-define=API_BASE_URL=http://10.0.2.2:8000
  // In prod: set to your deployed backend URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000', // Android emulator → host machine
  );

  static const timeout = Duration(seconds: 60);

  static Future<Map<String, String>> _authHeaders({
    bool json = true,
  }) async {
    final token = await AuthService.instance.getToken();
    if (token == null) {
      await AuthService.instance.handleUnauthorized();
      throw const UnauthorizedException();
    }
    return {
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> _send(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    final headers = await _authHeaders();
    final res = await request(headers).timeout(timeout);
    if (res.statusCode == 401) {
      await AuthService.instance.handleUnauthorized();
      throw const UnauthorizedException();
    }
    return res;
  }

  static Future<MatchResponse> matchAyahs(String entry, {int topN = 3}) async {
    final res = await _send(
      (headers) => http.post(
        Uri.parse('$baseUrl/match-ayahs'),
        headers: headers,
        body: jsonEncode({'entry': entry, 'top_n': topN}),
      ),
    );
    if (res.statusCode == 200) {
      return MatchResponse.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to match ayahs: ${res.statusCode}');
  }

  static Future<void> updateEmotion(int entryId, String emotionAfter) async {
    final res = await _send(
      (headers) => http.patch(
        Uri.parse('$baseUrl/history/$entryId/emotion'),
        headers: headers,
        body: jsonEncode({'emotion_after': emotionAfter}),
      ),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update emotion: ${res.statusCode}');
    }
  }

  static Future<List<HistoryItem>> getHistory() async {
    final res = await _send(
      (headers) => http.get(Uri.parse('$baseUrl/history'), headers: headers),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(res.bodyBytes));
      return data.map((e) => HistoryItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load history');
  }

  static Future<void> deleteEntry(int entryId) async {
    final res = await _send(
      (headers) => http.delete(
        Uri.parse('$baseUrl/history/$entryId'),
        headers: headers,
      ),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete entry: ${res.statusCode}');
    }
  }

  static Future<BookmarkItem> addBookmark(
    int ayahIndex, {
    String note = '',
  }) async {
    final res = await _send(
      (headers) => http.post(
        Uri.parse('$baseUrl/bookmark'),
        headers: headers,
        body: jsonEncode({'ayah_index': ayahIndex, 'note': note}),
      ),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return BookmarkItem.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to bookmark');
  }

  static Future<List<BookmarkItem>> getBookmarks() async {
    final res = await _send(
      (headers) => http.get(Uri.parse('$baseUrl/bookmarks'), headers: headers),
    );
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
    final res = await _send(
      (headers) => http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: headers,
        body: jsonEncode({
          'entry_id': entryId,
          'ayah_index': ayahIndex,
          'rating': rating,
        }),
      ),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to submit feedback: ${res.statusCode}');
    }
  }

  static Future<void> removeBookmark(int ayahIndex) async {
    final res = await _send(
      (headers) => http.delete(
        Uri.parse('$baseUrl/bookmark/$ayahIndex'),
        headers: headers,
      ),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to remove bookmark: ${res.statusCode}');
    }
  }

  static Future<WeeklyPattern> getPattern() async {
    final res = await _send(
      (headers) => http.get(Uri.parse('$baseUrl/pattern'), headers: headers),
    );
    if (res.statusCode == 200) {
      return WeeklyPattern.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
      );
    }
    if (res.statusCode == 404) {
      throw Exception('No history yet');
    }
    throw Exception('Failed to load pattern: ${res.statusCode}');
  }

  static Future<MatchResponse> reflectAgain(int entryId) async {
    final res = await _send(
      (headers) => http.post(
        Uri.parse('$baseUrl/reflect-again/$entryId'),
        headers: headers,
      ),
    );
    if (res.statusCode == 200) {
      return MatchResponse.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to reflect again');
  }
}
