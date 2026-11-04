import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase connection settings.
///
/// Nothing secret lives here: the anon key is a public client key, protected by
/// Row Level Security policies (see supabase/migrations/0001_init.sql).
///
/// Provide the values in ONE of these ways (no code edit needed):
///
///   1. `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
///   2. edit the two fallback constants below
///   3. web: `web/index.html` → `window.LIFE_SUPABASE_URL` (optional, see README)
class SupabaseConfig {
  const SupabaseConfig._();

  static const String _urlFromEnv =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _anonFromEnv =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// ↓↓↓ Paste your project values here if you are not using --dart-define.
  static const String _urlFallback = 'https://zaljyzpxcnrugmyjlhuc.supabase.co';
  static const String _anonFallback = 'sb_publishable_-_02mXV3wym0gJbns4q5yw_i8M-sJ8-';

  static String get url =>
      _urlFromEnv.isNotEmpty ? _urlFromEnv : _urlFallback;
  static String get anonKey =>
      _anonFromEnv.isNotEmpty ? _anonFromEnv : _anonFallback;

  /// True when both a URL and a key are present.
  static bool get isConfigured =>
      url.startsWith('http') && anonKey.length > 20;

  static bool _initialized = false;

  /// Boots the Supabase client. Returns false when config is missing, in which
  /// case the app falls back to Firebase or demo mode instead of crashing.
  static Future<bool> initialize() async {
    if (_initialized) return true;
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint(
          'Supabase not configured — pass SUPABASE_URL / SUPABASE_ANON_KEY '
          'via --dart-define (see README_SUPABASE.md).',
        );
      }
      return false;
    }
    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _initialized = true;
    return true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
