import 'storage_backend.dart';
import 'storage_backend_web.dart' if (dart.library.io) 'storage_backend_native.dart';

class JsonStorageService {
  static StorageBackend get _backend => createStorageBackend();

  static Future<Map<String, dynamic>> load() => _backend.load();
  static Future<void> save(Map<String, dynamic> data) => _backend.save(data);
  static Future<void> clear() => _backend.clear();
}
