import 'package:flutter/foundation.dart';

/// Google OAuth client IDs — from app_config.properties via run_app.ps1 / --dart-define.
class GoogleAuthConfig {
  static const webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static const iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  static bool get isConfigured {
    if (webClientId.isEmpty) return false;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return iosClientId.isNotEmpty;
    }
    return true;
  }

  static String get missingConfigMessage {
    if (webClientId.isEmpty) {
      return 'Run .\\sync_config.ps1 then flutter run -d chrome '
          '--dart-define-from-file=dart_defines.web.json\n'
          'Or use: .\\run_app.ps1 chrome';
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Set GOOGLE_IOS_CLIENT_ID in app_config.properties and ios/AppConfig.xcconfig.';
    }
    return 'Google Sign-In is not configured for this platform.';
  }

  static String? get iosReversedClientId {
    if (iosClientId.isEmpty) return null;
    const prefix = '.apps.googleusercontent.com';
    if (!iosClientId.endsWith(prefix)) return null;
    final id = iosClientId.substring(0, iosClientId.length - prefix.length);
    return 'com.googleusercontent.apps.$id';
  }
}
