import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

abstract class StorageBackend {
  Future<Map<String, dynamic>> load();
  Future<void> save(Map<String, dynamic> data);
  Future<void> clear();
}

class NativeStorageBackend implements StorageBackend {
  static String? _filePath;

  static Future<String> _getFilePath() async {
    if (_filePath != null) return _filePath!;
    final dir = await getApplicationDocumentsDirectory();
    _filePath = '${dir.path}/gastos_data.json';
    return _filePath!;
  }

  @override
  Future<Map<String, dynamic>> load() async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        return json.decode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
    return {'usuarios': [], 'tarjetas': [], 'gastos': []};
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      await file.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint('Error saving JSON: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error clearing JSON: $e');
    }
  }
}

class StorageBackendFactory {
  static StorageBackend create() => NativeStorageBackend();
}
