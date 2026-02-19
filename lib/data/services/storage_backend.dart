abstract class StorageBackend {
  Future<Map<String, dynamic>> load();
  Future<void> save(Map<String, dynamic> data);
  Future<void> clear();
}
