import '../models/models.dart';
import '../services/json_storage.dart';

class UsuarioRepository {
  Future<List<Usuario>> getAll() async {
    final data = await JsonStorageService.load();
    final usuariosList = data['usuarios'] as List<dynamic>? ?? [];
    return usuariosList
        .map((u) => Usuario.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  Stream<List<Usuario>> watchAll() {
    return Stream.fromFuture(getAll());
  }

  Future<Usuario> getById(int id) async {
    final usuarios = await getAll();
    try {
      return usuarios.firstWhere((u) => u.id == id);
    } catch (e) {
      throw Exception('Usuario no encontrado');
    }
  }

  Future<int> create(String nombre) async {
    final data = await JsonStorageService.load();
    final usuarios = data['usuarios'] as List;
    final newId = usuarios.isEmpty ? 1 : usuarios.map((u) => u['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    usuarios.add({'id': newId, 'nombre': nombre});
    await JsonStorageService.save(data);
    return newId;
  }

  Future<int> update(Usuario usuario) async {
    final data = await JsonStorageService.load();
    final usuarios = data['usuarios'] as List;
    for (int i = 0; i < usuarios.length; i++) {
      if (usuarios[i]['id'] == usuario.id) {
        usuarios[i] = {'id': usuario.id, 'nombre': usuario.nombre};
        await JsonStorageService.save(data);
        return 1;
      }
    }
    return 0;
  }

  Future<int> delete(int id) async {
    final data = await JsonStorageService.load();
    final usuarios = data['usuarios'] as List;
    final initialLength = usuarios.length;
    usuarios.removeWhere((u) => u['id'] == id);
    
    if (usuarios.length != initialLength) {
      final tarjetas = data['tarjetas'] as List;
      final tarjetasIds = tarjetas.where((t) => t['usuarioId'] == id).map((t) => t['id'] as int).toSet();
      tarjetas.removeWhere((t) => t['usuarioId'] == id);
      
      final gastos = data['gastos'] as List;
      gastos.removeWhere((g) => tarjetasIds.contains(g['tarjetaId']) || g['usuarioId'] == id);
      
      await JsonStorageService.save(data);
      return 1;
    }
    return 0;
  }
}
