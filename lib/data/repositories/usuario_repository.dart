import '../database/database_helper.dart';
import '../models/models.dart';

class UsuarioRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<List<Usuario>> getAll() async {
    final db = await _db.database;
    final result = await db.query('usuarios');
    return result.map((map) => Usuario.fromMap(map)).toList();
  }

  Stream<List<Usuario>> watchAll() {
    return Stream.fromFuture(getAll());
  }

  Future<Usuario> getById(int id) async {
    final db = await _db.database;
    final result = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    return Usuario.fromMap(result.first);
  }

  Future<int> create(String nombre) async {
    final db = await _db.database;
    return await db.insert('usuarios', {'nombre': nombre});
  }

  Future<int> update(Usuario usuario) async {
    final db = await _db.database;
    return await db.update('usuarios', usuario.toMap(), where: 'id = ?', whereArgs: [usuario.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }
}
