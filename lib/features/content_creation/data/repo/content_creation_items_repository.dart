import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/realtime_service.dart';
import '../model/content_creation_item_model.dart';

const contentCreationItemJoinedSelect =
    '*, clients(name, color), assignee:profiles!content_creation_items_assignee_id_fkey(*)';

class ContentCreationItemsRepository {
  ContentCreationItemsRepository(this._client, this._realtime);

  final SupabaseClient _client;
  final RealtimeService _realtime;

  Future<List<ContentCreationItemModel>> getItems() async {
    final rows = await _client
        .from('content_creation_items')
        .select(contentCreationItemJoinedSelect)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => ContentCreationItemModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Stream<void> watchItems() => _realtime.watchTable('content_creation_items');

  Future<ContentCreationItemModel> createItem(ContentCreationItemModel draft) async {
    final inserted = await _client
        .from('content_creation_items')
        .insert(draft.toInsertJson())
        .select('id')
        .single();
    final row = await _client
        .from('content_creation_items')
        .select(contentCreationItemJoinedSelect)
        .eq('id', inserted['id'] as String)
        .single();
    return ContentCreationItemModel.fromJson(row);
  }

  Future<void> updateItem(String id, Map<String, dynamic> changes) async {
    await _client.from('content_creation_items').update(changes).eq('id', id);
  }

  Future<void> updateStatus(String id, String status) async {
    await _client.from('content_creation_items').update({'status': status}).eq('id', id);
  }

  Future<void> deleteItem(String id) async {
    await _client.from('content_creation_items').delete().eq('id', id);
  }
}
