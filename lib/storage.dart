import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  static Future<void> write({
    required String key,
    required String value,
  }) async {
    await _storage.write(key: key, value: value);
  }

  static Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
