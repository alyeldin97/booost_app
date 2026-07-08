import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/realtime_service.dart';
import '../model/client_analytics_model.dart';
import '../model/client_model.dart';

class ClientsRepository {
  ClientsRepository(this._client, this._realtime);

  final SupabaseClient _client;
  final RealtimeService _realtime;

  Future<List<ClientModel>> getClients() async {
    final rows =
        await _client.from('clients').select().order('name', ascending: true);
    return (rows as List<dynamic>)
        .map((r) => ClientModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Stream<void> watchClients() => _realtime.watchTable('clients');

  Future<ClientModel> createClient({
    required String name,
    String? logoUrl,
    String? color,
  }) async {
    final row = await _client
        .from('clients')
        .insert({
          'name': name,
          'logo_url': logoUrl,
          'color': color,
          'created_by': _client.auth.currentUser?.id,
        })
        .select()
        .single();
    return ClientModel.fromJson(row);
  }

  Future<void> updateClient(String id, Map<String, dynamic> changes) async {
    await _client.from('clients').update(changes).eq('id', id);
  }

  Future<void> deleteClient(String id) async {
    await _client.from('clients').delete().eq('id', id);
  }

  Future<List<ClientAnalyticsModel>> getAnalytics(String clientId) async {
    final rows = await _client
        .from('client_analytics')
        .select()
        .eq('client_id', clientId)
        .order('week_start', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => ClientAnalyticsModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertAnalytics(ClientAnalyticsModel entry) async {
    await _client
        .from('client_analytics')
        .upsert(entry.toInsertJson(entry.clientId), onConflict: 'client_id,week_start');
  }

  Future<void> deleteAnalytics(String id) async {
    await _client.from('client_analytics').delete().eq('id', id);
  }
}
