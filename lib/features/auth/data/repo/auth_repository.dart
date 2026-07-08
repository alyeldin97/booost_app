import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/profile_model.dart';
import '../remote/auth_remote_data_source.dart';

class AuthRepository {
  AuthRepository(this._remote);

  final AuthRemoteDataSource _remote;

  Stream<AuthState> get onAuthStateChange => _remote.onAuthStateChange;
  bool get isAuthenticated => _remote.currentUser != null;
  String? get currentUserId => _remote.currentUser?.id;

  Future<void> signIn({required String email, required String password}) =>
      _remote.signInWithPassword(email: email, password: password);

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) =>
      _remote.signUp(email: email, password: password, fullName: fullName);

  Future<void> signOut() => _remote.signOut();

  Future<ProfileModel> fetchCurrentProfile() {
    final userId = currentUserId;
    if (userId == null) {
      throw StateError('No authenticated user to fetch a profile for.');
    }
    return _remote.fetchProfile(userId);
  }
}
