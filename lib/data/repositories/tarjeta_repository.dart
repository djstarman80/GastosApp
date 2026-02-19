import '../models/models.dart';
import '../services/json_storage.dart';

class TarjetaRepository {
  Future<List<Tarjeta>> getAll() async {
    final data = await JsonStorageService.load();
    final tarjetasList = data['tarjetas'] as List<dynamic>? ?? [];
    return tarjetasList
        .map((t) => Tarjeta.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Stream<List<Tarjeta>> watchAll() {
    return Stream.fromFuture(getAll());
  }

  Future<List<Tarjeta>> getByUsuario(int usuarioId) async {
    final tarjetas = await getAll();
    return tarjetas.where((t) => t.usuarioId == usuarioId).toList();
  }

  Stream<List<Tarjeta>> watchByUsuario(int usuarioId) {
    return Stream.fromFuture(getByUsuario(usuarioId));
  }

  Future<Tarjeta> getById(int id) async {
    final tarjetas = await getAll();
    try {
      return tarjetas.firstWhere((t) => t.id == id);
    } catch (e) {
      throw Exception('Tarjeta no encontrada');
    }
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
    final data = await JsonStorageService.load();
    final tarjetas = data['tarjetas'] as List;
    final newId = tarjetas.isEmpty ? 1 : tarjetas.map((t) => t['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    tarjetas.add({
      'id': newId,
      'tipo': tipo,
      'nombre': nombre,
      'banco': banco,
      'nombre_tarjeta': nombreTarjeta,
      'color': color,
      'limite': limite,
      'usuarioId': usuarioId,
      'fechaCierre': fechaCierre,
    });
    await JsonStorageService.save(data);
    return newId;
  }

  Future<int> update(Tarjeta tarjeta) async {
    final data = await JsonStorageService.load();
    final tarjetas = data['tarjetas'] as List;
    for (int i = 0; i < tarjetas.length; i++) {
      if (tarjetas[i]['id'] == tarjeta.id) {
        tarjetas[i] = {
          'id': tarjeta.id,
          'tipo': tarjeta.tipo,
          'nombre': tarjeta.nombre,
          'banco': tarjeta.banco,
          'nombre_tarjeta': tarjeta.nombreTarjeta,
          'color': tarjeta.color,
          'limite': tarjeta.limite,
          'usuarioId': tarjeta.usuarioId,
          'fechaCierre': tarjeta.fechaCierre,
        };
        await JsonStorageService.save(data);
        return 1;
      }
    }
    return 0;
  }

  Future<int> delete(int id) async {
    final data = await JsonStorageService.load();
    final tarjetas = data['tarjetas'] as List;
    final initialLength = tarjetas.length;
    tarjetas.removeWhere((t) => t['id'] == id);
    
    if (tarjetas.length != initialLength) {
      final gastos = data['gastos'] as List;
      gastos.removeWhere((g) => g['tarjetaId'] == id);
      await JsonStorageService.save(data);
      return 1;
    }
    return 0;
  }
}
