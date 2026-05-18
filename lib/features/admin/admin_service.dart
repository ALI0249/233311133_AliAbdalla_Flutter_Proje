import '../../core/logger.dart';
import '../../core/supabase_client.dart';
import '../profile/profile_model.dart';

class LogEntry {
  final int id;
  final String? userId;
  final String action;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final String? userFullName;

  const LogEntry({
    required this.id,
    this.userId,
    required this.action,
    this.metadata,
    required this.createdAt,
    this.userFullName,
  });

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'];
    return LogEntry(
      id: (map['id'] as num).toInt(),
      userId: map['user_id'] as String?,
      action: map['action'] as String,
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      userFullName:
          profile is Map ? profile['full_name'] as String? : null,
    );
  }
}

class AdminService {
  Future<List<Profile>> fetchAllProfiles() async {
    final data = await supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return (data as List)
        .map((p) => Profile.fromMap(p as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateProfileRole({
    required String profileId,
    required String newRole,
  }) async {
    assert(['ziyaretci', 'personel', 'admin'].contains(newRole));
    await supabase
        .from('profiles')
        .update({'role': newRole}).eq('id', profileId);
    await AppLogger.log('admin.role_change', metadata: {
      'profile_id': profileId,
      'new_role': newRole,
    });
  }

  Future<List<LogEntry>> fetchLogs({int limit = 100, String? action}) async {
    var builder =
        supabase.from('logs').select('*, profiles(full_name)');
    if (action != null) builder = builder.eq('action', action);
    final data =
        await builder.order('created_at', ascending: false).limit(limit);
    return (data as List)
        .map((l) => LogEntry.fromMap(l as Map<String, dynamic>))
        .toList();
  }
}
