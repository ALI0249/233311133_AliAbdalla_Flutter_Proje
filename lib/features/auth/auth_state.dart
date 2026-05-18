import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../profile/profile_model.dart';
import '../profile/profile_service.dart';
import 'auth_service.dart';

/// App-wide auth state. Listens to Supabase auth changes, fetches the
/// matching `profiles` row, and notifies listeners (router + screens).
class AuthState extends ChangeNotifier {
  AuthState({AuthService? authService, ProfileService? profileService})
      : _authService = authService ?? AuthService(),
        _profileService = profileService ?? ProfileService() {
    _sub = _authService.onAuthStateChange.listen((event) {
      _refresh();
    });
    _refresh();
  }

  final AuthService _authService;
  final ProfileService _profileService;
  StreamSubscription? _sub;

  Profile? _profile;
  bool _loading = true;

  Profile? get profile => _profile;
  bool get loading => _loading;
  bool get signedIn => _authService.currentUser != null;
  User? get user => _authService.currentUser;

  Future<void> _refresh() async {
    final u = _authService.currentUser;
    if (u == null) {
      _profile = null;
      _loading = false;
      notifyListeners();
      return;
    }
    try {
      _profile = await _profileService.fetchById(u.id);
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthState] profile fetch failed: $e');
      _profile = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
