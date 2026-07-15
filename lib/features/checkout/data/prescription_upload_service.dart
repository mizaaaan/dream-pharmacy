import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PrescriptionUploadService {
  final _client = Supabase.instance.client;
  static const _bucket = 'prescriptions';

  Future<String> upload({
    required String orderId,
    required Uint8List fileBytes,
    required String fileExtension,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final fileName = '${const Uuid().v4()}.$fileExtension';
    final path = '$userId/$orderId/$fileName';

    await _client.storage.from(_bucket).uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(upsert: false),
        );

    await _client.from('prescriptions').insert({
      'order_id': orderId,
      'file_url': path,
      'file_type': fileExtension == 'pdf' ? 'pdf' : 'image',
    });

    return path;
  }

  Future<String> getSignedUrl(String path, {int expiresInSeconds = 3600}) {
    return _client.storage.from(_bucket).createSignedUrl(path, expiresInSeconds);
  }
}
