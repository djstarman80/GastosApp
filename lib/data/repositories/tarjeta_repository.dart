import '../database/database_helper.dart';
import '../models/models.dart';

class TarjetaRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Tarjeta>> getAll() async {
    final db = await _db.database;
    final result = await db.query('tarjetas');
    return result.map((map) => Tarjeta.fromMap(map)).toList();
  }

  Stream<List<Tarjeta>> watchAll() {
    return Stream.fromFuture(getAll());
  }

  Future<List<Tarjeta>> getByUsuario(int usuarioId) async {
    final db = await _db.database;
    final result = await db.query('tarjetas', where: 'usuario_id = ?', whereArgs: [usuarioId]);
    return result.map((map) => Tarjeta.fromMap(map)).toList();
  }

  Stream<List<Tarjeta>> watchByUsuario(int usuarioId) {
    return Stream.fromFuture(getByUsuario(usuarioId));
  }

  Future<Tarjeta> getById(int id) async {
    final db = await _db.database;
    final result = await db.query('tarjetas', where: 'id = ?', whereArgs: [id]);
    return Tarjeta.fromMap(result.first);
  }

  Future<int> create({
    required String tipo,
    required String nombre,
    required String banco,
    required String nombreTarjeta,
    required String color,
    double? limite,
    required int usuarioId,
    int? fechaCierre,
  }) async {
    final db = await _db.database;
    return await db.insert('tarjetas', {
      'tipo': tipo,
      'nombre': nombre,
      'banco': banco,
      'nombre_tarjeta': nombreTarjeta,
      'color': color,
      'limite': limite,
      'usuario_id': usuarioId,
      'fecha_cierre': fechaCierre,
    });
  }

  Future<int> update(Tarjeta tarjeta) async {
    final db = await _db.database;
    return await db.update('tarjetas', tarjeta.toMap(), where: 'id = ?', whereArgs: [tarjeta.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('tarjetas', where: 'id = ?', whereArgs: [id]);
  }
}
