import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/realtime_service.dart';
import '../model/note_model.dart';

class NotesRepository {
  NotesRepository(this._client, this._realtime);

  final SupabaseClient _client;
  final RealtimeService _realtime;

  Future<List<NoteModel>> getNotes() async {
    final rows = await _client
        .from('notes')
        .select('*, profiles(full_name)')
        .order('updated_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => NoteModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Stream<void> watchNotes() => _realtime.watchTable('notes');

  Future<NoteModel> createNote({String title = 'Untitled', String? content}) async {
    final row = await _client
        .from('notes')
        .insert({
          'title': title,
          'content': content,
          'created_by': _client.auth.currentUser?.id,
        })
        .select('*, profiles(full_name)')
        .single();
    return NoteModel.fromJson(row);
  }

  Future<void> updateNote(String id, Map<String, dynamic> changes) async {
    await _client.from('notes').update(changes).eq('id', id);
  }

  Future<void> deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
  }
}
