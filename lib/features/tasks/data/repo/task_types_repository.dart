import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/exceptions/lookup_delete_restricted_exception.dart';
import '../../../../core/services/realtime_service.dart';
import '../model/task_type_model.dart';

class TaskTypesRepository {
  TaskTypesRepository(this._client, this._realtime);

  final SupabaseClient _client;
  final RealtimeService _realtime;

  Future<List<TaskTypeModel>> getTypes() async {
    final rows =
        await _client.from('task_types').select().order('position', ascending: true);
    return (rows as List<dynamic>)
        .map((r) => TaskTypeModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Stream<void> watchTypes() => _realtime.watchTable('task_types');

  Future<void> renameType(String taskType, String title) async {
    await _client.from('task_types').update({'title': title}).eq('task_type', taskType);
  }

  Future<TaskTypeModel> createType(String title, int nextPosition) async {
    final row = await _client
        .from('task_types')
        .insert({'task_type': _slugify(title), 'title': title, 'position': nextPosition})
        .select()
        .single();
    return TaskTypeModel.fromJson(row);
  }

  /// Throws [LookupDeleteRestrictedException] if tasks still use this type.
  Future<void> deleteType(String taskType) async {
    try {
      await _client.from('task_types').delete().eq('task_type', taskType);
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
    return '${base.isEmpty ? 'type' : base}_$suffix';
  }
}
