import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/exceptions/lookup_delete_restricted_exception.dart';
import '../../../../core/services/realtime_service.dart';
import '../model/platform_model.dart';

class PlatformsRepository {
  PlatformsRepository(this._client, this._realtime);

  final SupabaseClient _client;
  final RealtimeService _realtime;

  Future<List<PlatformModel>> getPlatforms() async {
    final rows =
        await _client.from('platforms').select().order('position', ascending: true);
    return (rows as List<dynamic>)
        .map((r) => PlatformModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Stream<void> watchPlatforms() => _realtime.watchTable('platforms');

  Future<void> renamePlatform(String platform, String title) async {
    await _client.from('platforms').update({'title': title}).eq('platform', platform);
  }

  Future<PlatformModel> createPlatform(String title, int nextPosition) async {
    final row = await _client
        .from('platforms')
        .insert({'platform': _slugify(title), 'title': title, 'position': nextPosition})
        .select()
        .single();
    return PlatformModel.fromJson(row);
  }

  /// Throws [LookupDeleteRestrictedException] if tasks or content items
  /// still use this platform.
  Future<void> deletePlatform(String platform) async {
    try {
      await _client.from('platforms').delete().eq('platform', platform);
    } on PostgrestException catch (e) {
      if (e.code == '23503') throw const LookupDeleteRestrictedException();
      rethrow;
    }
  }

  String _slugify(String title) {
    final base = title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final suffix = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    return '${base.isEmpty ? 'platform' : base}_$suffix';
  }
}
