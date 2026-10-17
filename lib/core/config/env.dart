/// Build-time configuration.
///
/// Pass your Supabase project with:
///   flutter run --dart-define-from-file=env/supabase.json
/// (copy env/supabase.example.json → env/supabase.json and fill it in).
///
/// The publishable (or legacy anon) key is safe to ship in the app: every
/// table is protected by row level security (supabase/migrations).
abstract class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const _publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const supabaseKey = _publishableKey == '' ? _anonKey : _publishableKey;

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
