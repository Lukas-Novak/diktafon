/// Upload token storage — Android Keystore / iOS Keychain via
/// flutter_secure_storage. The token must NOT live in the Drift settings
/// table: that database is covered by OS cloud backup, the credential must
/// not leave the device in an export the user didn't explicitly make
/// (`migrateWithBackup` stays at its default false for the same reason).
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UploadTokenStore {
  UploadTokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'uploadToken';

  Future<String?> read() async {
    final value = await _storage.read(key: _key);
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  Future<void> write(String? token) async {
    final trimmed = token?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _storage.delete(key: _key);
    } else {
      await _storage.write(key: _key, value: trimmed);
    }
  }
}
