import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/activity_log_model.dart';

class ActivityLogRepository {
  ActivityLogRepository(this._client);

  final SupabaseClient _client;

  Future<void> logAction({
    String? taskId,
    String? contentItemId,
    required String action,
    Map<String, dynamic> metadata = const {},
  }) async {
    await _client.from('activity_logs').insert({
      'actor_id': _client.auth.currentUser?.id,
      'task_id': taskId,
      'content_item_id': contentItemId,
      'action': action,
      'metadata': metadata,
    });
  }

  Future<List<ActivityLogModel>> getActivityForTask(String taskId) async {
    final rows = await _client
        .from('activity_logs')
        .select('*, profiles(full_name, avatar_url)')
        .eq('task_id', taskId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => ActivityLogModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
