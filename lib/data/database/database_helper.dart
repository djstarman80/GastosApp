import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void initializeDatabaseFactory() {}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static final WebDatabaseImpl? _webDb = kIsWeb ? WebDatabaseImpl() : null;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  bool get isWeb => kIsWeb;

  Future<dynamic> get database async {
    if (kIsWeb) {
      return _webDb!;
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = p.join(dbFolder.path, 'gastos.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
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
  static final Map<String, List<Map<String, dynamic>>> _tables = {
    'usuarios': [],
    'tarjetas': [],
    'gastos': [],
  };
  static int _idUsuarios = 1;
  static int _idTarjetas = 1;
  static int _idGastos = 1;

  List<Map<String, dynamic>> query(String table, {String? where, List<dynamic>? whereArgs}) {
    if (!_tables.containsKey(table)) return [];
    
    var results = List<Map<String, dynamic>>.from(_tables[table]!);
    
    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      results = results.where((row) {
        if (where.contains('=')) {
          final parts = where.split('=');
          final column = parts[0].trim();
          final value = whereArgs[0];
          return row[column] == value;
        }
        return true;
      }).toList();
    }
    
    return results;
  }

  int insert(String table, Map<String, dynamic> values) {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    
    int id;
    switch (table) {
      case 'usuarios':
        id = _idUsuarios++;
        break;
      case 'tarjetas':
        id = _idTarjetas++;
        break;
      case 'gastos':
        id = _idGastos++;
        break;
      default:
        id = _tables[table]!.length + 1;
    }
    
    final newRow = {...values, 'id': id};
    _tables[table]!.add(newRow);
    return id;
  }

  int update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs}) {
    if (!_tables.containsKey(table)) return 0;
    
    int count = 0;
    for (int i = 0; i < _tables[table]!.length; i++) {
      bool matches = true;
      if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
        if (where.contains('=')) {
          final parts = where.split('=');
          final column = parts[0].trim();
          final value = whereArgs[0];
          matches = _tables[table]![i][column] == value;
        }
      }
      
      if (matches) {
        _tables[table]![i] = {..._tables[table]![i], ...values};
        count++;
      }
    }
    return count;
  }

  int delete(String table, {String? where, List<dynamic>? whereArgs}) {
    if (!_tables.containsKey(table)) return 0;
    
    final toRemove = <int>[];
    for (int i = 0; i < _tables[table]!.length; i++) {
      bool shouldDelete = false;
      if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
        if (where.contains('=')) {
          final parts = where.split('=');
          final column = parts[0].trim();
          final value = whereArgs[0];
          shouldDelete = _tables[table]![i][column] == value;
        }
      }
      if (shouldDelete) toRemove.add(i);
    }
    
    for (int i = toRemove.length - 1; i >= 0; i--) {
      _tables[table]!.removeAt(toRemove[i]);
    }
    return toRemove.length;
  }

  Map<String, dynamic> exportData() {
    return {
      'usuarios': _tables['usuarios'],
      'tarjetas': _tables['tarjetas'],
      'gastos': _tables['gastos'],
    };
  }

  void importData(Map<String, dynamic> data) {
    _tables['usuarios'] = List<Map<String, dynamic>>.from(data['usuarios'] ?? []);
    _tables['tarjetas'] = List<Map<String, dynamic>>.from(data['tarjetas'] ?? []);
    _tables['gastos'] = List<Map<String, dynamic>>.from(data['gastos'] ?? []);
    
    _idUsuarios = (_tables['usuarios']!.isEmpty ? 0 : _tables['usuarios']!.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
    _idTarjetas = (_tables['tarjetas']!.isEmpty ? 0 : _tables['tarjetas']!.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
    _idGastos = (_tables['gastos']!.isEmpty ? 0 : _tables['gastos']!.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
  }

  void clear() {
    _tables['usuarios'] = [];
    _tables['tarjetas'] = [];
    _tables['gastos'] = [];
    _idUsuarios = 1;
    _idTarjetas = 1;
    _idGastos = 1;
  }
}
