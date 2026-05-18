import 'package:flutter/foundation.dart';
import 'supabase_client.dart';

/// Cross-cutting action logger. Every service method writes a row to the
/// `logs` table in Supabase via [AppLogger.log]. Failures of the log insert
/// are themselves printed to debug console but NEVER thrown back to the
/// caller — logging must not break user actions.
class AppLogger {
  static Future<void> log(
    String action, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      await supabase.from('logs').insert({
        'user_id': userId,
        'action': action,
        'metadata': metadata,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppLogger] failed to write log "$action": $e');
      }
    }
  }
}
