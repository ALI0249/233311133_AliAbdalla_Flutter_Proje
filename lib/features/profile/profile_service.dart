import '../../core/supabase_client.dart';
import 'profile_model.dart';

class ProfileService {
  Future<Profile?> fetchById(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromMap(data);
  }

  Future<void> updateOwnProfile({
    required String userId,
    String? fullName,
    String? phone,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (updates.isEmpty) return;
    await supabase.from('profiles').update(updates).eq('id', userId);
  }
}
