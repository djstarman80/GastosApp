import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/backup_data.dart';
import '../database/database_helper.dart';

// Import condicional para plataformas no-web
import 'dart:io' if (dart.library.html) 'backup_service_io_stub.dart';

class BackupService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<String> exportToJson() async {
    final db = await _db.database;
    
    final usuariosResult = await db.query('usuarios');
    final usuarios = usuariosResult.map((m) => Usuario.fromMap(m)).toList();
    
    final tarjetasResult = await db.query('tarjetas');
    final tarjetas = tarjetasResult.map((m) => Tarjeta.fromMap(m)).toList();
    
    final gastosResult = await db.query('gastos');
    final gastos = gastosResult.map((m) => Gasto.fromMap(m)).toList();
    
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
    
    final db = await _db.database;
    final isWeb = kIsWeb;
    
    if (replace) {
      if (isWeb) {
        final webDb = db as WebDatabaseImpl;
        await webDb.clear();
      } else {
        await db.delete('gastos');
        await db.delete('tarjetas');
        await db.delete('usuarios');
      }
    }
    
    // Importar usuarios
    final usuarioIdMap = <int, int>{};
    for (final usuario in backup.usuarios) {
      if (isWeb) {
        final webDb = db as WebDatabaseImpl;
        final newId = await webDb.insert('usuarios', {'nombre': usuario.nombre});
        usuarioIdMap[usuario.id] = newId;
      } else {
        final newId = await db.insert('usuarios', {'nombre': usuario.nombre});
        usuarioIdMap[usuario.id] = newId;
      }
    }
    
    // Importar tarjetas
    final tarjetaIdMap = <int, int>{};
    for (final tarjeta in backup.tarjetas) {
      final oldUsuarioId = tarjeta.usuarioId;
      final newUsuarioId = usuarioIdMap[oldUsuarioId];
      if (newUsuarioId != null) {
        if (isWeb) {
          final webDb = db as WebDatabaseImpl;
          final newId = await webDb.insert('tarjetas', {
            'tipo': tarjeta.tipo,
            'nombre': tarjeta.nombre,
            'banco': tarjeta.banco,
            'nombre_tarjeta': tarjeta.nombreTarjeta,
            'color': tarjeta.color,
            'limite': tarjeta.limite,
            'usuario_id': newUsuarioId,
            'fecha_cierre': tarjeta.fechaCierre,
          });
          tarjetaIdMap[tarjeta.id] = newId;
        } else {
          final newId = await db.insert('tarjetas', {
            'tipo': tarjeta.tipo,
            'nombre': tarjeta.nombre,
            'banco': tarjeta.banco,
            'nombre_tarjeta': tarjeta.nombreTarjeta,
            'color': tarjeta.color,
            'limite': tarjeta.limite,
            'usuario_id': newUsuarioId,
            'fecha_cierre': tarjeta.fechaCierre,
          });
          tarjetaIdMap[tarjeta.id] = newId;
        }
      }
    }
    
    // Importar gastos
    for (final gasto in backup.gastos) {
      final oldUsuarioId = gasto.usuarioId;
      final oldTarjetaId = gasto.tarjetaId;
      final newUsuarioId = usuarioIdMap[oldUsuarioId];
      final newTarjetaId = tarjetaIdMap[oldTarjetaId];
      
      if (newUsuarioId != null && newTarjetaId != null) {
        if (isWeb) {
          final webDb = db as WebDatabaseImpl;
          await webDb.insert('gastos', {
            'monto': gasto.monto,
            'descripcion': gasto.descripcion,
            'tarjeta_id': newTarjetaId,
            'usuario_id': newUsuarioId,
            'cuotas': gasto.cuotas,
            'es_recurrente': gasto.esRecurrente ? 1 : 0,
            'fecha': gasto.fecha,
            'fecha_pago': gasto.fechaPago,
            'pagado': gasto.pagado ? 1 : 0,
          });
        } else {
          await db.insert('gastos', {
            'monto': gasto.monto,
            'descripcion': gasto.descripcion,
            'tarjeta_id': newTarjetaId,
            'usuario_id': newUsuarioId,
            'cuotas': gasto.cuotas,
            'es_recurrente': gasto.esRecurrente ? 1 : 0,
            'fecha': gasto.fecha,
            'fecha_pago': gasto.fechaPago,
            'pagado': gasto.pagado ? 1 : 0,
          });
        }
      }
    }
  }
}
