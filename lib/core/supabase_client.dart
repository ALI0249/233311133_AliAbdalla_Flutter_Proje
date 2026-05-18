import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // ============================================================
  // REPLACE THESE TWO VALUES with your own Supabase project's
  // credentials from https://app.supabase.com -> Project Settings -> API
  // The anon key is safe to ship in client code; Row Level Security
  // policies are what protect the data.
  // ============================================================
  static const String url = 'https://YOUR-PROJECT-ID.supabase.co';
  static const String anonKey = 'YOUR-SUPABASE-ANON-KEY';
}

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
