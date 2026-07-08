import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/profile_model.dart';

abstract class AuthRemoteDataSource {
  Stream<AuthState> get onAuthStateChange;
  User? get currentUser;

  Future<void> signInWithPassword({required String email, required String password});
  Future<void> signUp({required String email, required String password, String? fullName});
  Future<void> signOut();
  Future<ProfileModel> fetchProfile(String userId);
}

class SupabaseAuthDataSource implements AuthRemoteDataSource {
  SupabaseAuthDataSource(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<ProfileModel> fetchProfile(String userId) async {
    final row =
        await _client.from('profiles').select().eq('id', userId).single();
    return ProfileModel.fromJson(row);
  }
}
