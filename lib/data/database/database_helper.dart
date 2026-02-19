import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void initializeDatabaseFactory() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static WebDatabaseImpl? _webDb;
  static String? _dbPath;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal() {
    if (kIsWeb && _webDb == null) {
      _webDb = WebDatabaseImpl();
    }
  }

  bool get isWeb => kIsWeb;

  static void resetDatabase() {
    debugPrint('DEBUG: resetDatabase called');
    if (_database != null && _database!.isOpen) {
      debugPrint('DEBUG: Closing database');
      _database!.close();
    }
    _database = null;
    debugPrint('DEBUG: Database reset, _database is now: $_database');
  }

  Future<dynamic> get database async {
    debugPrint('DEBUG: get database called, _database: $_database');
    if (kIsWeb) {
      await _webDb!.init();
      return _webDb!;
    }
    if (_database != null && _database!.isOpen) {
      debugPrint('DEBUG: Returning cached database');
      return _database!;
    }
    debugPrint('DEBUG: Creating new database connection');
    _database = await _initDatabase();
    debugPrint('DEBUG: New database created, _database: $_database');
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (_dbPath == null) {
      final dbFolder = await getApplicationDocumentsDirectory();
      _dbPath = p.join(dbFolder.path, 'gastos.db');
    }
    return await openDatabase(_dbPath!, version: 1, onCreate: _onCreate, singleInstance: true);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tarjetas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        nombre TEXT NOT NULL,
        banco TEXT NOT NULL,
        nombre_tarjeta TEXT NOT NULL,
        color TEXT NOT NULL,
        limite REAL,
        usuario_id INTEGER NOT NULL,
        fecha_cierre INTEGER,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monto REAL NOT NULL,
        descripcion TEXT NOT NULL,
        tarjeta_id INTEGER NOT NULL,
        usuario_id INTEGER NOT NULL,
        cuotas INTEGER,
        es_recurrente INTEGER DEFAULT 0,
        fecha INTEGER NOT NULL,
        fecha_pago INTEGER,
        pagado INTEGER DEFAULT 0,
        FOREIGN KEY (tarjeta_id) REFERENCES tarjetas (id) ON DELETE CASCADE,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');
  }
}

class WebDatabaseImpl {
  bool _initialized = false;
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  int _nextIdUsuario = 1;
  int _nextIdTarjeta = 1;
  int _nextIdGasto = 1;
  static const String _storageKey = 'gastosapp_db';
  SharedPreferences? _prefs;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _tables['usuarios'] = [];
    _tables['tarjetas'] = [];
    _tables['gastos'] = [];
    
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
      await _loadFromStorage();
    }
  }

  Future<void> _loadFromStorage() async {
    if (_prefs == null) return;
    try {
      final data = _prefs!.getString(_storageKey);
      if (data != null && data.isNotEmpty) {
        final Map<String, dynamic> parsed = jsonDecode(data);
        _tables['usuarios'] = List<Map<String, dynamic>>.from(parsed['usuarios'] ?? []);
        _tables['tarjetas'] = List<Map<String, dynamic>>.from(parsed['tarjetas'] ?? []);
        _tables['gastos'] = List<Map<String, dynamic>>.from(parsed['gastos'] ?? []);
        
        _nextIdUsuario = _getMaxId(_tables['usuarios']!) + 1;
        _nextIdTarjeta = _getMaxId(_tables['tarjetas']!) + 1;
        _nextIdGasto = _getMaxId(_tables['gastos']!) + 1;
      }
    } catch (e) {
      debugPrint('Error loading from storage: $e');
    }
  }

  int _getMaxId(List<Map<String, dynamic>> table) {
    if (table.isEmpty) return 0;
    int maxId = 0;
    for (var row in table) {
      final id = row['id'];
      if (id != null && id is num && id.toInt() > maxId) {
        maxId = id.toInt();
      }
    }
    return maxId;
  }

  Future<void> _saveToStorage() async {
    if (_prefs == null) return;
    try {
      final data = jsonEncode({
        'usuarios': _tables['usuarios'],
        'tarjetas': _tables['tarjetas'],
        'gastos': _tables['gastos'],
      });
      await _prefs!.setString(_storageKey, data);
    } catch (e) {
      debugPrint('Save storage error: $e');
    }
  }

  List<Map<String, dynamic>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    
    var results = List<Map<String, dynamic>>.from(_tables[table]!);
    
    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      final whereClean = where.replaceAll(' ', '');
      results = results.where((row) {
        if (whereClean.contains('=')) {
          final parts = whereClean.split('=');
          final column = parts[0].toLowerCase();
          final value = whereArgs[0];
          final rowValue = row[column];
          return rowValue == value;
        }
        return true;
      }).toList();
    }
    
    if (orderBy != null && orderBy.isNotEmpty) {
      final orderColumn = orderBy.replaceAll('DESC', '').replaceAll('ASC', '').trim().toLowerCase();
      final descending = orderBy.toUpperCase().contains('DESC');
      results.sort((a, b) {
        final aVal = a[orderColumn];
        final bVal = b[orderColumn];
        if (aVal is Comparable && bVal is Comparable) {
          return descending ? bVal.compareTo(aVal) : aVal.compareTo(bVal);
        }
        return 0;
      });
    }
    
    return results;
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    
    final normalizedValues = <String, dynamic>{};
    values.forEach((key, value) {
      normalizedValues[key.toLowerCase()] = value;
    });
    
    int id;
    switch (table.toLowerCase()) {
      case 'usuarios':
        id = _nextIdUsuario++;
        break;
      case 'tarjetas':
        id = _nextIdTarjeta++;
        break;
      case 'gastos':
        id = _nextIdGasto++;
        break;
      default:
        id = _getMaxId(_tables[table]!) + 1;
    }
    
    final newRow = {...normalizedValues, 'id': id};
    _tables[table]!.add(newRow);
    await _saveToStorage();
    return id;
  }

  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs}) async {
    if (!_tables.containsKey(table)) return 0;
    
    final normalizedValues = <String, dynamic>{};
    values.forEach((key, value) {
      normalizedValues[key.toLowerCase()] = value;
    });
    
    int count = 0;
    final whereClean = where?.replaceAll(' ', '') ?? '';
    
    for (int i = 0; i < _tables[table]!.length; i++) {
      bool matches = true;
      if (whereClean.isNotEmpty && whereArgs != null && whereArgs.isNotEmpty) {
        if (whereClean.contains('=')) {
          final parts = whereClean.split('=');
          final column = parts[0].toLowerCase();
          final value = whereArgs[0];
          matches = _tables[table]![i][column] == value;
        }
      }
      
      if (matches) {
        _tables[table]![i] = {..._tables[table]![i], ...normalizedValues};
        count++;
      }
    }
    if (count > 0) await _saveToStorage();
    return count;
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    if (!_tables.containsKey(table)) return 0;
    
    final toRemove = <int>[];
    final whereClean = where?.replaceAll(' ', '') ?? '';
    
    for (int i = 0; i < _tables[table]!.length; i++) {
      bool shouldDelete = false;
      if (whereClean.isNotEmpty && whereArgs != null && whereArgs.isNotEmpty) {
        if (whereClean.contains('=')) {
          final parts = whereClean.split('=');
          final column = parts[0].toLowerCase();
          final value = whereArgs[0];
          shouldDelete = _tables[table]![i][column] == value;
        }
      }
      if (shouldDelete) toRemove.add(i);
    }
    
    for (int i = toRemove.length - 1; i >= 0; i--) {
      _tables[table]!.removeAt(toRemove[i]);
    }
    if (toRemove.isNotEmpty) await _saveToStorage();
    return toRemove.length;
  }

  Map<String, dynamic> exportData() {
    return {
      'usuarios': _tables['usuarios'],
      'tarjetas': _tables['tarjetas'],
      'gastos': _tables['gastos'],
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    _tables['usuarios'] = List<Map<String, dynamic>>.from(data['usuarios'] ?? []);
    _tables['tarjetas'] = List<Map<String, dynamic>>.from(data['tarjetas'] ?? []);
    _tables['gastos'] = List<Map<String, dynamic>>.from(data['gastos'] ?? []);
    
    _nextIdUsuario = _getMaxId(_tables['usuarios']!) + 1;
    _nextIdTarjeta = _getMaxId(_tables['tarjetas']!) + 1;
    _nextIdGasto = _getMaxId(_tables['gastos']!) + 1;
    
    await _saveToStorage();
  }

  Future<void> clear() async {
    _tables['usuarios'] = [];
    _tables['tarjetas'] = [];
    _tables['gastos'] = [];
    _nextIdUsuario = 1;
    _nextIdTarjeta = 1;
    _nextIdGasto = 1;
    await _saveToStorage();
  }
}
