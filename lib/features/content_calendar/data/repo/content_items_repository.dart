import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/realtime_service.dart';
import '../../../../core/utils/app_enums.dart';
import '../model/content_item_model.dart';
import '../remote/content_items_remote_data_source.dart';

class ContentItemsRepository {
  ContentItemsRepository(this._client, this._realtime);

  final SupabaseClient _client;
  final RealtimeService _realtime;

  Future<List<ContentItemModel>> getContentItems() async {
    final rows = await _client
        .from('content_items')
        .select(contentItemJoinedSelect)
        .order('publish_at', ascending: true);
    return (rows as List<dynamic>)
        .map((r) => ContentItemModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Stream<void> watchContentItems() => _realtime.watchTable('content_items');

  Future<ContentItemModel> createContentItem(ContentItemModel draft) async {
    final inserted = await _client
        .from('content_items')
        .insert(draft.toInsertJson())
        .select('id')
        .single();
    final row = await _client
        .from('content_items')
        .select(contentItemJoinedSelect)
        .eq('id', inserted['id'] as String)
        .single();
    return ContentItemModel.fromJson(row);
  }

  Future<void> updateContentItem(String id, Map<String, dynamic> changes) async {
    await _client.from('content_items').update(changes).eq('id', id);
  }

  /// Drag-and-drop reschedule path. The DB trigger
  /// `content_items_sync_task_due_date` is the authoritative sync for any
  /// linked task's due_date; this call alone is sufficient — callers don't
  /// need to separately patch the task record for correctness, only for
  /// perceived responsiveness before the realtime pulse arrives.
  Future<void> rescheduleContentItem(String id, DateTime newPublishAt) async {
    await _client
        .from('content_items')
        .update({'publish_at': newPublishAt.toIso8601String()}).eq('id', id);
  }

  Future<void> updateApprovalStatus(String id, ApprovalStatus status) async {
    await _client
        .from('content_items')
        .update({'approval_status': status.dbValue}).eq('id', id);
  }

  Future<void> deleteContentItem(String id) async {
    await _client.from('content_items').delete().eq('id', id);
  }
}
