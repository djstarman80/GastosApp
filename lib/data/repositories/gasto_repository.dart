import '../models/models.dart';
import '../services/json_storage.dart';

class GastoRepository {
  Future<List<Gasto>> getAll() async {
    final data = await JsonStorageService.load();
    final gastosList = data['gastos'] as List<dynamic>? ?? [];
    final gastos = gastosList
        .map((g) => Gasto.fromJson(g as Map<String, dynamic>))
        .toList();
    gastos.sort((a, b) => b.fecha.compareTo(a.fecha));
    return gastos;
  }

  Stream<List<Gasto>> watchAll() {
    return Stream.fromFuture(getAll());
  }

  Future<List<Gasto>> getByUsuario(int usuarioId) async {
    final gastos = await getAll();
    return gastos.where((g) => g.usuarioId == usuarioId).toList();
  }

  Stream<List<Gasto>> watchByUsuario(int usuarioId) {
    return Stream.fromFuture(getByUsuario(usuarioId));
  }

  Future<List<Gasto>> getByTarjeta(int tarjetaId) async {
    final gastos = await getAll();
    return gastos.where((g) => g.tarjetaId == tarjetaId).toList();
  }

  Future<List<Gasto>> getByFechaRange(int startDate, int endDate) async {
    final gastos = await getAll();
    return gastos.where((g) => g.fecha >= startDate && g.fecha <= endDate).toList();
  }

  Future<Gasto> getById(int id) async {
    final gastos = await getAll();
    try {
      return gastos.firstWhere((g) => g.id == id);
    } catch (e) {
      throw Exception('Gasto no encontrado');
    }
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
    final data = await JsonStorageService.load();
    final gastos = data['gastos'] as List;
    final newId = gastos.isEmpty ? 1 : gastos.map((g) => g['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    gastos.add({
      'id': newId,
      'monto': monto,
      'descripcion': descripcion,
      'tarjetaId': tarjetaId,
      'usuarioId': usuarioId,
      'cuotas': cuotas,
      'esRecurrente': esRecurrente,
      'fecha': fecha,
      'fechaPago': fechaPago,
      'pagado': pagado,
    });
    await JsonStorageService.save(data);
    return newId;
  }

  Future<int> update(Gasto gasto) async {
    final data = await JsonStorageService.load();
    final gastos = data['gastos'] as List;
    for (int i = 0; i < gastos.length; i++) {
      if (gastos[i]['id'] == gasto.id) {
        gastos[i] = {
          'id': gasto.id,
          'monto': gasto.monto,
          'descripcion': gasto.descripcion,
          'tarjetaId': gasto.tarjetaId,
          'usuarioId': gasto.usuarioId,
          'cuotas': gasto.cuotas,
          'esRecurrente': gasto.esRecurrente,
          'fecha': gasto.fecha,
          'fechaPago': gasto.fechaPago,
          'pagado': gasto.pagado,
        };
        await JsonStorageService.save(data);
        return 1;
      }
    }
    return 0;
  }

  Future<int> delete(int id) async {
    final data = await JsonStorageService.load();
    final gastos = data['gastos'] as List;
    final initialLength = gastos.length;
    gastos.removeWhere((g) => g['id'] == id);
    if (gastos.length != initialLength) {
      await JsonStorageService.save(data);
      return 1;
    }
    return 0;
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
