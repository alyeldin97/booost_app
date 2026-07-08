import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/realtime_service.dart';
import '../../../../core/utils/app_enums.dart';
import '../model/task_model.dart';
import '../remote/tasks_remote_data_source.dart';

class TasksRepository {
  TasksRepository(this._client, this._realtime);

  final SupabaseClient _client;
  final RealtimeService _realtime;

  Future<List<TaskModel>> getTasks() async {
    final rows = await _client
        .from('tasks')
        .select(taskJoinedSelect)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => TaskModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> getTask(String id) async {
    final row = await _client
        .from('tasks')
        .select(taskJoinedSelect)
        .eq('id', id)
        .single();
    return TaskModel.fromJson(row);
  }

  /// Pulses whenever tasks (or the sub-resources visible on a Kanban card)
  /// change, for any user — callers should re-fetch on each event.
  Stream<void> watchTasks() {
    return _realtime.watchTable('tasks');
  }

  Future<TaskModel> createTask({
    required String clientId,
    required String title,
    String? description,
    String status = 'todo',
    TaskPriority priority = TaskPriority.medium,
    String taskType = 'internal',
    DateTime? dueDate,
  }) async {
    // Insert plain (no joined select on the POST — a select() this wide
    // piggybacked on an insert request has been unreliable in some
    // browsers), then fetch the full joined row via a normal GET.
    final inserted = await _client
        .from('tasks')
        .insert({
          'client_id': clientId,
          'title': title,
          'description': description,
          'status': status,
          'priority': priority.dbValue,
          'task_type': taskType,
          'due_date': dueDate?.toIso8601String(),
          'created_by': _client.auth.currentUser?.id,
        })
        .select('id')
        .single();
    return getTask(inserted['id'] as String);
  }

  Future<void> updateTask(String id, Map<String, dynamic> changes) async {
    await _client.from('tasks').update(changes).eq('id', id);
  }

  Future<void> updateTaskStatus(String id, String status) async {
    await _client.from('tasks').update({'status': status}).eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }

  Future<void> addAssignee(String taskId, String profileId) async {
    await _client.from('task_assignees').upsert({
      'task_id': taskId,
      'profile_id': profileId,
    });
  }

  Future<void> removeAssignee(String taskId, String profileId) async {
    await _client
        .from('task_assignees')
        .delete()
        .eq('task_id', taskId)
        .eq('profile_id', profileId);
  }

  /// Replaces the full platform tag set for a task (delete-all then
  /// insert), matching how the drawer edits platforms as one multi-select.
  Future<void> setPlatforms(String taskId, List<String> platforms) async {
    await _client.from('task_platforms').delete().eq('task_id', taskId);
    if (platforms.isEmpty) return;
    await _client.from('task_platforms').insert(
          platforms.map((p) => {'task_id': taskId, 'platform': p}).toList(),
        );
  }

  Future<void> addLabel(String taskId, String label) async {
    await _client.from('task_labels').insert({'task_id': taskId, 'label': label});
  }

  Future<void> removeLabel(String labelId) async {
    await _client.from('task_labels').delete().eq('id', labelId);
  }

  Future<void> addChecklistItem(String taskId, String title, int position) async {
    await _client.from('task_checklist_items').insert({
      'task_id': taskId,
      'title': title,
      'position': position,
    });
  }

  Future<void> toggleChecklistItem(String itemId, bool isCompleted) async {
    await _client
        .from('task_checklist_items')
        .update({'is_completed': isCompleted}).eq('id', itemId);
  }

  Future<void> deleteChecklistItem(String itemId) async {
    await _client.from('task_checklist_items').delete().eq('id', itemId);
  }

  Future<void> addAttachmentRecord({
    required String taskId,
    required String fileName,
    required String fileUrl,
    String? fileType,
  }) async {
    await _client.from('task_attachments').insert({
      'task_id': taskId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'uploaded_by': _client.auth.currentUser?.id,
    });
  }

  Future<void> deleteAttachmentRecord(String attachmentId) async {
    await _client.from('task_attachments').delete().eq('id', attachmentId);
  }

  Future<void> addComment(String taskId, String content) async {
    await _client.from('task_comments').insert({
      'task_id': taskId,
      'profile_id': _client.auth.currentUser?.id,
      'content': content,
    });
  }
}
