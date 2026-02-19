import 'dart:convert';
import 'dart:io';
import '../models/models.dart';
import '../models/backup_data.dart';
import 'json_storage.dart';

class BackupService {
  Future<String> exportToJson() async {
    final data = await JsonStorageService.load();
    
    final usuarios = (data['usuarios'] as List<dynamic>?)
        ?.map((u) => Usuario.fromJson(u as Map<String, dynamic>))
        .toList() ?? [];
    
    final tarjetas = (data['tarjetas'] as List<dynamic>?)
        ?.map((t) => Tarjeta.fromJson(t as Map<String, dynamic>))
        .toList() ?? [];
    
    final gastos = (data['gastos'] as List<dynamic>?)
        ?.map((g) => Gasto.fromJson(g as Map<String, dynamic>))
        .toList() ?? [];
    
    final backup = BackupData(
      usuarios: usuarios,
      tarjetas: tarjetas,
      gastos: gastos,
      version: '1.0',
    );
    
    return jsonEncode(backup.toJson());
  }

  Future<void> exportToFile(String filePath) async {
    final json = await exportToJson();
    final file = File(filePath);
    await file.writeAsString(json);
  }

  Future<BackupData?> importFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return BackupData.fromJson(json);
    } catch (e) {
      throw Exception('Error al parsear JSON: $e');
    }
  }

  Future<void> importFromFile(String filePath, {bool replace = false}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Archivo no encontrado');
    }
    
    final jsonString = await file.readAsString();
    await importData(jsonString, replace: replace);
  }

  Future<void> importData(String jsonString, {bool replace = false}) async {
    final backup = await importFromJson(jsonString);
    if (backup == null) {
      throw Exception('No se pudo parsear el backup');
    }
    
    final data = replace ? <String, dynamic>{
      'usuarios': <Map<String, dynamic>>[],
      'tarjetas': <Map<String, dynamic>>[],
      'gastos': <Map<String, dynamic>>[],
    } : await JsonStorageService.load();
    
    final usuarioIdMap = <int, int>{};
    final newUsuarioId = (data['usuarios'] as List).length + 1;
    
    for (int i = 0; i < backup.usuarios.length; i++) {
      final usuario = backup.usuarios[i];
      final newId = newUsuarioId + i;
      usuarioIdMap[usuario.id] = newId;
      (data['usuarios'] as List).add({
        'id': newId,
        'nombre': usuario.nombre,
      });
    }
    
    final newTarjetaId = (data['tarjetas'] as List).length + 1;
    final tarjetaIdMap = <int, int>{};
    
    for (int i = 0; i < backup.tarjetas.length; i++) {
      final tarjeta = backup.tarjetas[i];
      final oldUsuarioId = tarjeta.usuarioId;
      final newUserId = usuarioIdMap[oldUsuarioId];
      
      if (newUserId != null) {
        final newId = newTarjetaId + i;
        tarjetaIdMap[tarjeta.id] = newId;
        (data['tarjetas'] as List).add({
          'id': newId,
          'tipo': tarjeta.tipo,
          'nombre': tarjeta.nombre,
          'banco': tarjeta.banco,
          'nombre_tarjeta': tarjeta.nombreTarjeta,
          'color': tarjeta.color,
          'limite': tarjeta.limite,
          'usuarioId': newUserId,
          'fechaCierre': tarjeta.fechaCierre,
        });
      }
    }
    
    final newGastoId = (data['gastos'] as List).length + 1;
    
    for (int i = 0; i < backup.gastos.length; i++) {
      final gasto = backup.gastos[i];
      final oldUsuarioId = gasto.usuarioId;
      final oldTarjetaId = gasto.tarjetaId;
      final newUserId = usuarioIdMap[oldUsuarioId];
      final newTarjId = tarjetaIdMap[oldTarjetaId];
      
      if (newUserId != null && newTarjId != null) {
        final newId = newGastoId + i;
        (data['gastos'] as List).add({
          'id': newId,
          'monto': gasto.monto,
          'descripcion': gasto.descripcion,
          'tarjetaId': newTarjId,
          'usuarioId': newUserId,
          'cuotas': gasto.cuotas,
          'esRecurrente': gasto.esRecurrente,
          'fecha': gasto.fecha,
          'fechaPago': gasto.fechaPago,
          'pagado': gasto.pagado,
        });
      }
    }
    
    await JsonStorageService.save(data);
  }
}
