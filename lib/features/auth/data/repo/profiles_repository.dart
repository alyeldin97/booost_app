import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/profile_model.dart';

class ProfilesRepository {
  ProfilesRepository(this._client);

  final SupabaseClient _client;

  Future<List<ProfileModel>> getProfiles() async {
    final rows = await _client.from('profiles').select().order('full_name');
    return (rows as List<dynamic>)
        .map((r) => ProfileModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
