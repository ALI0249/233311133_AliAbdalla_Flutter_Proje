import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/logger.dart';
import '../../core/supabase_client.dart';

class AuthService {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    await AppLogger.log('auth.register', metadata: {'email': email});
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    await AppLogger.log('auth.login', metadata: {'email': email});
    return response;
  }

  Future<void> signOut() async {
    final email = supabase.auth.currentUser?.email;
    await AppLogger.log('auth.logout', metadata: {'email': email});
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;
  Session? get currentSession => supabase.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;
}
