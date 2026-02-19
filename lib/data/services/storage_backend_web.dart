import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageBackend {
  Future<Map<String, dynamic>> load();
  Future<void> save(Map<String, dynamic> data);
  Future<void> clear();
}

class WebStorageBackend implements StorageBackend {
  static SharedPreferences? _prefs;
  static const String _storageKey = 'gastosapp_data';

  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<Map<String, dynamic>> load() async {
    try {
      final prefs = await _preferences;
      final data = prefs.getString(_storageKey);
      if (data != null && data.isNotEmpty) {
        return json.decode(data) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
    return {'usuarios': [], 'tarjetas': [], 'gastos': []};
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    try {
      final prefs = await _preferences;
      await prefs.setString(_storageKey, json.encode(data));
    } catch (e) {
      debugPrint('Error saving JSON: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Error clearing JSON: $e');
    }
  }
}

class StorageBackendFactory {
  static StorageBackend create() => WebStorageBackend();
}
