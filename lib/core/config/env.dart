/// Build-time configuration.
///
/// Pass your Supabase project with:
///   flutter run --dart-define-from-file=env/supabase.json
/// (copy env/supabase.example.json → env/supabase.json and fill it in).
///
/// The publishable (or legacy anon) key is safe to ship in the app: every
/// table is protected by row level security (supabase/migrations).
///
/// Without defines the app uses the hosted demo project (shared temporarily
/// with the clinic_queue Supabase project, for showing the app to customers).
abstract class Env {
  static const _demoUrl = 'https://axncazensmjdqpczvzwf.supabase.co';
  static const _demoKey = 'sb_publishable_7hGIGHFa1mcWPMI8mEZKGw_-wgkkSYT';

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: _demoUrl);

  static const _publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: _demoKey);
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const supabaseKey = _publishableKey == '' ? _anonKey : _publishableKey;

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
