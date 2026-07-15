import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: false,
    );
  }
}

SupabaseClient get supabase => Supabase.instance.client;
