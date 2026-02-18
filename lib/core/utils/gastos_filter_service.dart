import '../../data/models/models.dart';
import 'cuota_utils.dart';

/// Servicio centralizado para filtrar gastos por mes/año
class GastosFilterService {
  /// Obtiene los gastos de un mes específico, aplicando lógica de cuotas y recurrentes
  static List<Map<String, dynamic>> getGastosDelMes({
    required List<Gasto> gastos,
    required List<Tarjeta> tarjetas,
    required int selectedYear,
    required int selectedMonth,
    int? usuarioId,
    int? tarjetaId,
  }) {
    final result = <Map<String, dynamic>>[];

    // Filtrar por usuario o tarjeta si se especifica
    var filteredGastos = gastos;
    if (usuarioId != null) {
      filteredGastos = gastos.where((g) => g.usuarioId == usuarioId).toList();
    }
    if (tarjetaId != null) {
      filteredGastos = filteredGastos.where((g) => g.tarjetaId == tarjetaId).toList();
    }

    for (final g in filteredGastos) {
      final fechaGasto = DateTime.fromMillisecondsSinceEpoch(g.fecha);
      double montoMostrar = g.monto;
      
      final tarjeta = tarjetas.where((t) => t.id == g.tarjetaId).firstOrNull;
      final fechaCierre = tarjeta?.fechaCierre;
      
      if (g.esRecurrente) {
        // Gastos recurrentes
        final mesResumen = fechaCierre != null 
            ? CuotaUtils.calcularMesResumen(fechaGasto, fechaCierre)
            : fechaGasto;
            
        if (selectedYear < mesResumen.year || 
            (selectedYear == mesResumen.year && selectedMonth >= mesResumen.month)) {
          montoMostrar = g.monto;
          result.add({
            'gasto': g, 
            'monto': montoMostrar, 
            'esRecurrente': true,
            'tarjeta': tarjeta,
          });
        }
      } else if (g.cuotas != null && g.cuotas! > 0) {
        // Gastos en cuotas
        if (fechaCierre != null) {
          if (CuotaUtils.debeAparecerEnMes(
            fechaGasto, 
            fechaCierre, 
            g.cuotas, 
            selectedYear, 
            selectedMonth
          )) {
            montoMostrar = g.monto / g.cuotas!;
            result.add({
              'gasto': g, 
              'monto': montoMostrar, 
              'esRecurrente': false,
              'tarjeta': tarjeta,
              'cuotaActual': CuotaUtils.calcularCuotaActual(
                fechaGasto, fechaCierre, g.cuotas!, selectedYear, selectedMonth
              ),
              'totalCuotas': g.cuotas,
            });
          }
        } else {
          // Sin fecha de cierre, usar lógica simple
          final mesInicio = fechaGasto.month;
          final anioInicio = fechaGasto.year;
          int mesesTranscurridos = (selectedYear - anioInicio) * 12 + (selectedMonth - mesInicio);
          if (mesesTranscurridos >= 0 && mesesTranscurridos < g.cuotas!) {
            montoMostrar = g.monto / g.cuotas!;
            result.add({
              'gasto': g, 
              'monto': montoMostrar, 
              'esRecurrente': false,
              'tarjeta': tarjeta,
              'cuotaActual': mesesTranscurridos + 1,
              'totalCuotas': g.cuotas,
            });
          }
        }
      } else {
        // Gastos de contado
        if (fechaCierre != null) {
          final mesResumen = CuotaUtils.calcularMesResumen(fechaGasto, fechaCierre);
          if (mesResumen.year == selectedYear && mesResumen.month == selectedMonth) {
            montoMostrar = g.monto;
            result.add({
              'gasto': g, 
              'monto': montoMostrar, 
              'esRecurrente': false,
              'tarjeta': tarjeta,
            });
          }
        } else {
          if (fechaGasto.year == selectedYear && fechaGasto.month == selectedMonth) {
            montoMostrar = g.monto;
            result.add({
              'gasto': g, 
              'monto': montoMostrar, 
              'esRecurrente': false,
              'tarjeta': tarjeta,
            });
          }
        }
      }
    }
    
    return result;
  }

  /// Calcula el total de gastos de un mes
  static double calcularTotalMes(List<Map<String, dynamic>> gastosDelMes) {
    return gastosDelMes.fold(0.0, (sum, g) => sum + (g['monto'] as double));
  }

  /// Agrupa gastos por tarjeta
  static Map<String, List<Map<String, dynamic>>> agruparPorTarjeta(
    List<Map<String, dynamic>> gastosDelMes,
    List<Tarjeta> tarjetas,
  ) {
    final result = <String, List<Map<String, dynamic>>>{};
    
    for (final g in gastosDelMes) {
      final tarjeta = g['tarjeta'] as Tarjeta?;
      final nombreTarjeta = tarjeta?.nombre ?? 'Sin Tarjeta';
      
      if (!result.containsKey(nombreTarjeta)) {
        result[nombreTarjeta] = [];
      }
      result[nombreTarjeta]!.add(g);
    }
    
    return result;
  }

  /// Agrupa gastos por usuario
  static Map<String, List<Map<String, dynamic>>> agruparPorUsuario(
    List<Map<String, dynamic>> gastosDelMes,
    List<Usuario> usuarios,
  ) {
    final result = <String, List<Map<String, dynamic>>>{};
    
    for (final g in gastosDelMes) {
      final gasto = g['gasto'] as Gasto;
      final usuario = usuarios.where((u) => u.id == gasto.usuarioId).firstOrNull;
      final nombreUsuario = usuario?.nombre ?? 'Sin Usuario';
      
      if (!result.containsKey(nombreUsuario)) {
        result[nombreUsuario] = [];
      }
      result[nombreUsuario]!.add(g);
    }
    
    return result;
  }
}
