import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Emits a dumb "this table changed" pulse per table — it deliberately
/// does not try to diff/merge realtime payloads itself, since Supabase's
/// per-row payloads don't include the joined relations our models need
/// (assignees, platforms, client name, ...). Each repository's watch*()
/// wraps this and re-fetches through the normal joined query on every
/// pulse, which is also what keeps this safe to share across every
/// screen instead of opening one channel per view.
class RealtimeService {
  RealtimeService(this._client);

  final SupabaseClient _client;
  final _channels = <String, RealtimeChannel>{};

  Stream<void> watchTable(String table) {
    late final StreamController<void> controller;
    controller = StreamController<void>.broadcast(
      onCancel: () {
        final channel = _channels.remove(table);
        if (channel != null) _client.removeChannel(channel);
      },
    );

    final channel = _client.channel('public:$table')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (payload) {
          if (!controller.isClosed) controller.add(null);
        },
      )
      ..subscribe();

    _channels[table] = channel;
    return controller.stream;
  }
}
