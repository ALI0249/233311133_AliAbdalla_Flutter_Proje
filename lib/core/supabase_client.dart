import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // ============================================================
  // REPLACE THESE TWO VALUES with your own Supabase project's
  // credentials from https://app.supabase.com -> Project Settings -> API
  // The anon key is safe to ship in client code; Row Level Security
  // policies are what protect the data.
  // ============================================================
  static const String url = 'https://hnlzbagediyjzcygeegg.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhubHpiYWdlZGl5anpjeWdlZWdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxMjQyODAsImV4cCI6MjA5NDcwMDI4MH0.St8-zNBlHUKpTI7LUmWdkI4PoLpGvCmO6tsJ7dRIedM';
}

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
