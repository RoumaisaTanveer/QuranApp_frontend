import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../config/google_auth_config.dart';
import '../screens/login_screen.dart';
import 'api_service.dart';

class AuthUser {
  final int id;
  final String email;
  final String? displayName;
  final String createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        email: json['email'] as String,
        displayName: json['display_name'] as String?,
        createdAt: json['created_at'] as String? ?? '',
      );
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();
}

/// Google Sign-In (web / Android / iOS) → POST /auth/google → app JWT.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const _tokenKey = 'access_token';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  late final GoogleSignIn _googleSignIn = _createGoogleSignIn();

  String? _cachedToken;

  /// Platform-specific GoogleSignIn:
  /// - Web:     clientId only (serverClientId NOT supported on web plugin)
  /// - Android: serverClientId = web client (yields id_token aud = web client)
  /// - iOS:     clientId = iOS client, serverClientId = web client
  static GoogleSignIn _createGoogleSignIn() {
    const scopes = ['email', 'profile', 'openid'];
    final webId = GoogleAuthConfig.webClientId;
    final iosId = GoogleAuthConfig.iosClientId;

    if (kIsWeb) {
      return GoogleSignIn(
        scopes: scopes,
        clientId: webId.isEmpty ? null : webId,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return GoogleSignIn(
          scopes: scopes,
          clientId: iosId.isEmpty ? null : iosId,
          serverClientId: webId.isEmpty ? null : webId,
        );
      case TargetPlatform.android:
        return GoogleSignIn(
          scopes: scopes,
          serverClientId: webId.isEmpty ? null : webId,
        );
      default:
        return GoogleSignIn(
          scopes: scopes,
          clientId: webId.isEmpty ? null : webId,
        );
    }
  }

  Future<String?> getToken() async {
    _cachedToken ??= await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  Future<void> handleUnauthorized() async {
    await clearToken();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> signInWithGoogle() async {
    if (!GoogleAuthConfig.isConfigured) {
      throw AuthException(GoogleAuthConfig.missingConfigMessage);
    }

    GoogleSignInAccount? account;
    try {
      account = await _googleSignIn.signIn();
    } catch (e) {
      throw AuthException(_friendlyGoogleError(e));
    }
    if (account == null) {
      throw const AuthException('Sign in cancelled.');
    }

    GoogleSignInAuthentication googleAuth;
    try {
      googleAuth = await account.authentication;
    } catch (e) {
      throw AuthException(_friendlyGoogleError(e));
    }

    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    final Map<String, String> body;
    if (idToken != null) {
      body = {'id_token': idToken};
    } else if (kIsWeb && accessToken != null) {
      // Flutter web signIn() returns access_token, not id_token (GIS SDK limitation)
      body = {'access_token': accessToken};
    } else {
      throw AuthException(
        'No Google token received. Enable People API in Google Cloud, '
        'then full-restart the app and try again.',
      );
    }

    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(ApiService.timeout);
    } catch (e) {
      throw AuthException(
        'Backend not reachable at ${ApiService.baseUrl}\n'
        'Start backend: cd D:\\QuranApp && uvicorn main:app --reload --host 0.0.0.0 --port 8000\n'
        '($e)',
      );
    }

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      await _saveToken(data['access_token'] as String);
      return;
    }
    if (res.statusCode == 401) {
      throw const AuthException(
        'Google sign-in was rejected. Ensure backend GOOGLE_CLIENT_IDS includes your web and iOS client IDs.',
      );
    }
    if (res.statusCode == 403) {
      throw const AuthException('This account has been deactivated.');
    }
    throw AuthException(
      'Google sign-in failed (${res.statusCode})',
      statusCode: res.statusCode,
    );
  }

  Future<AuthUser> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw const UnauthorizedException();
    }

    final res = await http
        .get(
          Uri.parse('${ApiService.baseUrl}/auth/me'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(ApiService.timeout);

    if (res.statusCode == 401) {
      await handleUnauthorized();
      throw const UnauthorizedException();
    }
    if (res.statusCode != 200) {
      throw AuthException('Could not load profile (${res.statusCode})');
    }
    return AuthUser.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<AuthUser> updateDisplayName(String displayName) async {
    final name = displayName.trim();
    if (name.isEmpty) {
      throw const AuthException('Display name cannot be empty.');
    }

    final res = await http
        .patch(
          Uri.parse('${ApiService.baseUrl}/auth/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await getToken()}',
          },
          body: jsonEncode({'display_name': name}),
        )
        .timeout(ApiService.timeout);

    if (res.statusCode == 401) {
      await handleUnauthorized();
      throw const UnauthorizedException();
    }
    if (res.statusCode != 200) {
      throw AuthException('Could not update name (${res.statusCode})');
    }
    return AuthUser.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }

  static String _friendlyGoogleError(Object e) {
    final msg = e.toString();
    if (msg.contains('people.googleapis.com') ||
        msg.contains('People API') ||
        msg.contains('SERVICE_DISABLED')) {
      return 'Enable Google People API in Cloud Console, wait 2 min, then retry.\n'
          'https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=998396667150';
    }
    if (msg.contains('origin_mismatch')) {
      return 'Google origin_mismatch — use port 8080 and add http://localhost:8080 to JavaScript origins.';
    }
    return 'Google sign-in failed. $msg';
  }

  Future<bool> validateSession() async {
    if (!await hasToken()) return false;
    try {
      await getCurrentUser();
      return true;
    } on UnauthorizedException {
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<void> logout() async {
    await clearToken();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
