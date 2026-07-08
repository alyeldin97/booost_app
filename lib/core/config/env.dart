import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads Supabase config from `--dart-define-from-file` (used for the
/// production/Vercel build) first, falling back to `flutter_dotenv`
/// (used for local `flutter run -d chrome`). Feature code should only
/// ever go through [Env] and never branch on which source is active.
class Env {
  Env._();

  static const _dartDefineUrl = String.fromEnvironment('SUPABASE_URL');
  static const _dartDefineAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<void> load() async {
    if (_dartDefineUrl.isNotEmpty && _dartDefineAnonKey.isNotEmpty) {
      return;
    }
    await dotenv.load(fileName: '.env');
  }

  static String get supabaseUrl =>
      _dartDefineUrl.isNotEmpty ? _dartDefineUrl : _require('SUPABASE_URL');

  static String get supabaseAnonKey => _dartDefineAnonKey.isNotEmpty
      ? _dartDefineAnonKey
      : _require('SUPABASE_ANON_KEY');

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required env var "$key". Set it in .env for local dev '
        'or via --dart-define-from-file for production builds.',
      );
    }
    return value;
  }
}
