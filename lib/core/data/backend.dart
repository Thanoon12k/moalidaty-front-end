import 'package:get/get.dart';

import '../config/env.dart';
import 'data_source.dart';
import 'demo_data_source.dart';
import 'supabase_data_source.dart';

/// Holds the active [DataSource]: Supabase when the app is configured,
/// otherwise (or when the user taps "try the app") the in-memory demo.
class Backend extends GetxService {
  Backend({DataSource? remote}) : _remote = remote ?? (Env.hasSupabase ? SupabaseDataSource() : null);

  final DataSource? _remote;
  DataSource? _demo;
  late DataSource _active = _remote ?? (_demo ??= DemoDataSource());

  DataSource get source => _active;
  bool get hasRemote => _remote != null;
  bool get isDemo => _active.isDemo;

  DataSource useDemo() => _active = _demo ??= DemoDataSource();

  void useRemote() {
    if (_remote != null) _active = _remote;
    _demo = null; // a fresh demo next time
  }
}
