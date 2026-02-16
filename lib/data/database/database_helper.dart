import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void initializeDatabaseFactory() {}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
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
