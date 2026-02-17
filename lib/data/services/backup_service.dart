import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/models.dart';
import '../models/backup_data.dart';
import '../database/database_helper.dart';

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
    
    // Usar métodos directos para web
    if (kIsWeb) {
      final webDb = db as WebDatabaseImpl;
      
      if (replace) {
        webDb.clear();
      }
      
      // Importar usuarios
      final usuarioIdMap = <int, int>{};
      for (final usuario in backup.usuarios) {
        final newId = webDb.insert('usuarios', {
          'nombre': usuario.nombre,
        });
        usuarioIdMap[usuario.id] = newId;
      }
      
      // Importar tarjetas
      final tarjetaIdMap = <int, int>{};
      for (final tarjeta in backup.tarjetas) {
        final oldUsuarioId = tarjeta.usuarioId;
        final newUsuarioId = usuarioIdMap[oldUsuarioId];
        if (newUsuarioId != null) {
          final newId = webDb.insert('tarjetas', {
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
      
      // Importar gastos
      for (final gasto in backup.gastos) {
        final oldUsuarioId = gasto.usuarioId;
        final oldTarjetaId = gasto.tarjetaId;
        final newUsuarioId = usuarioIdMap[oldUsuarioId];
        final newTarjetaId = tarjetaIdMap[oldTarjetaId];
        
        if (newUsuarioId != null && newTarjetaId != null) {
          webDb.insert('gastos', {
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
      return;
    }
    
    // Código original para SQLite (móvil/escritorio)
    if (replace) {
      await db.delete('gastos');
      await db.delete('tarjetas');
      await db.delete('usuarios');
    }
    
    final usuarioIdMap = <int, int>{};
    for (final usuario in backup.usuarios) {
      final newId = await db.insert('usuarios', {
        'nombre': usuario.nombre,
      });
      usuarioIdMap[usuario.id] = newId;
    }
    
    final tarjetaIdMap = <int, int>{};
    for (final tarjeta in backup.tarjetas) {
      final oldUsuarioId = tarjeta.usuarioId;
      final newUsuarioId = usuarioIdMap[oldUsuarioId];
      if (newUsuarioId != null) {
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
    
    for (final gasto in backup.gastos) {
      final oldUsuarioId = gasto.usuarioId;
      final oldTarjetaId = gasto.tarjetaId;
      final newUsuarioId = usuarioIdMap[oldUsuarioId];
      final newTarjetaId = tarjetaIdMap[oldTarjetaId];
      
      if (newUsuarioId != null && newTarjetaId != null) {
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
