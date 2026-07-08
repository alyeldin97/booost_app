import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService(this._client);

  static const bucket = 'task-attachments';
  final SupabaseClient _client;
  final _uuid = const Uuid();

  /// Uploads a picked file under `<taskId>/<uuid>_<fileName>` and returns
  /// the object path (not a public URL — the bucket is private, so reads
  /// go through [signedUrl]).
  Future<String> uploadTaskAttachment({
    required String taskId,
    required PlatformFile file,
  }) async {
    final path = '$taskId/${_uuid.v4()}_${file.name}';
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('File "${file.name}" has no readable bytes.');
    }
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _mimeTypeFor(file.extension)),
        );
    return path;
  }

  Future<String> signedUrl(String path, {int expiresInSeconds = 3600}) {
    return _client.storage.from(bucket).createSignedUrl(path, expiresInSeconds);
  }

  Future<void> deleteAttachment(String path) {
    return _client.storage.from(bucket).remove([path]);
  }

  Future<Uint8List> download(String path) {
    return _client.storage.from(bucket).download(path);
  }

  String? _mimeTypeFor(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'pdf':
        return 'application/pdf';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'webp':
        return 'image/webp';
      default:
        return null;
    }
  }
}
