import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/exceptions/lookup_delete_restricted_exception.dart';
import '../../../../core/services/realtime_service.dart';
import '../model/board_column_model.dart';

class BoardColumnsRepository {
  BoardColumnsRepository(this._client, this._realtime);

  final SupabaseClient _client;
  final RealtimeService _realtime;

  Future<List<BoardColumnModel>> getColumns() async {
    final rows =
        await _client.from('board_columns').select().order('position', ascending: true);
    return (rows as List<dynamic>)
        .map((r) => BoardColumnModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Stream<void> watchColumns() => _realtime.watchTable('board_columns');

  Future<void> renameColumn(String status, String title) async {
    await _client.from('board_columns').update({'title': title}).eq('status', status);
  }

  Future<BoardColumnModel> createColumn(String title, int nextPosition) async {
    final slug = _slugify(title);
    final row = await _client
        .from('board_columns')
        .insert({'status': slug, 'title': title, 'position': nextPosition})
        .select()
        .single();
    return BoardColumnModel.fromJson(row);
  }

  /// Throws [LookupDeleteRestrictedException] if tasks still reference
  /// this column (the DB foreign key enforces this — callers should move or
  /// delete those tasks first).
  Future<void> deleteColumn(String status) async {
    try {
      await _client.from('board_columns').delete().eq('status', status);
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
    return '${base.isEmpty ? 'column' : base}_$suffix';
  }
}
