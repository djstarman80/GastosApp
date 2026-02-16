import '../database/database_helper.dart';
import '../models/models.dart';

class GastoRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Gasto>> getAll() async {
    final db = await _db.database;
    final result = await db.query('gastos', orderBy: 'fecha DESC');
    return result.map((map) => Gasto.fromMap(map)).toList();
  }

  Stream<List<Gasto>> watchAll() {
    return Stream.fromFuture(getAll());
  }

  Future<List<Gasto>> getByUsuario(int usuarioId) async {
    final db = await _db.database;
    final result = await db.query('gastos', where: 'usuario_id = ?', whereArgs: [usuarioId], orderBy: 'fecha DESC');
    return result.map((map) => Gasto.fromMap(map)).toList();
  }

  Stream<List<Gasto>> watchByUsuario(int usuarioId) {
    return Stream.fromFuture(getByUsuario(usuarioId));
  }

  Future<List<Gasto>> getByTarjeta(int tarjetaId) async {
    final db = await _db.database;
    final result = await db.query('gastos', where: 'tarjeta_id = ?', whereArgs: [tarjetaId]);
    return result.map((map) => Gasto.fromMap(map)).toList();
  }

  Future<List<Gasto>> getByFechaRange(int startDate, int endDate) async {
    final db = await _db.database;
    final result = await db.query('gastos', where: 'fecha >= ? AND fecha <= ?', whereArgs: [startDate, endDate]);
    return result.map((map) => Gasto.fromMap(map)).toList();
  }

  Future<Gasto> getById(int id) async {
    final db = await _db.database;
    final result = await db.query('gastos', where: 'id = ?', whereArgs: [id]);
    return Gasto.fromMap(result.first);
  }

  Future<int> create({
    required double monto,
    required String descripcion,
    required int tarjetaId,
    required int usuarioId,
    int? cuotas,
    bool esRecurrente = false,
    required int fecha,
    int? fechaPago,
    bool pagado = false,
  }) async {
    final db = await _db.database;
    return await db.insert('gastos', {
      'monto': monto,
      'descripcion': descripcion,
      'tarjeta_id': tarjetaId,
      'usuario_id': usuarioId,
      'cuotas': cuotas,
      'es_recurrente': esRecurrente ? 1 : 0,
      'fecha': fecha,
      'fecha_pago': fechaPago,
      'pagado': pagado ? 1 : 0,
    });
  }

  Future<int> update(Gasto gasto) async {
    final db = await _db.database;
    return await db.update('gastos', gasto.toMap(), where: 'id = ?', whereArgs: [gasto.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalByUsuario(int usuarioId) async {
    final gastos = await getByUsuario(usuarioId);
    double total = 0;
    for (final gasto in gastos) {
      total += gasto.monto;
    }
    return total;
  }
}
