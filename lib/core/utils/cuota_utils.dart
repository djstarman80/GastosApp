import '../../data/models/models.dart';

/// Utilidades para cálculos de cuotas y fechas de cierre
class CuotaInfo {
  final int cuotaActual;
  final int totalCuotas;
  final double valorCuota;
  final DateTime? fechaUltima;
  final bool esRecurrente;
  final bool esContado;

  CuotaInfo({
    required this.cuotaActual,
    required this.totalCuotas,
    required this.valorCuota,
    this.fechaUltima,
    required this.esRecurrente,
    required this.esContado,
  });

  String toFormattedString({String currencySymbol = '\$'}) {
    if (esRecurrente) return 'Recurrente';
    if (esContado) return 'Contado';
    final fecha = fechaUltima != null ? _formatMonthYear(fechaUltima!) : '-';
    return 'Cuota $cuotaActual/$totalCuotas ($currencySymbol${valorCuota.toStringAsFixed(0)}) | Última: $fecha';
  }

  String get cuotasStr {
    if (esRecurrente) return 'Recurrente';
    if (esContado) return '-';
    return '$cuotaActual/$totalCuotas';
  }

  String get ultimaStr {
    if (esRecurrente || esContado || fechaUltima == null) return '-';
    return _formatMonthYear(fechaUltima!);
  }

  String _formatMonthYear(DateTime date) {
    final mes = date.month.toString().padLeft(2, '0');
    return '$mes/${date.year}';
  }
}

class CuotaUtils {
  static CuotaInfo calcularCuotaInfo(
    Gasto gasto,
    Tarjeta? tarjeta, {
    DateTime? fechaReferencia,
  }) {
    final ahora = fechaReferencia ?? DateTime.now();
    
    if (gasto.esRecurrente) {
      return CuotaInfo(
        cuotaActual: 0,
        totalCuotas: 0,
        valorCuota: gasto.monto,
        fechaUltima: null,
        esRecurrente: true,
        esContado: false,
      );
    }
    
    if (gasto.cuotas == null || gasto.cuotas == 0 || gasto.cuotas == 1) {
      DateTime? fechaResumen;
      if (tarjeta?.fechaCierre != null) {
        final fechaGasto = DateTime.fromMillisecondsSinceEpoch(gasto.fecha);
        fechaResumen = calcularMesResumen(fechaGasto, tarjeta!.fechaCierre!);
      }
      return CuotaInfo(
        cuotaActual: 0,
        totalCuotas: 0,
        valorCuota: gasto.monto,
        fechaUltima: fechaResumen,
        esRecurrente: false,
        esContado: true,
      );
    }
    
    final fechaGasto = DateTime.fromMillisecondsSinceEpoch(gasto.fecha);
    final int cuotas = gasto.cuotas!;
    final valorCuota = gasto.monto / cuotas;
    
    int cuotaActual;
    DateTime ultimaCuotaDate;
    
    if (tarjeta?.fechaCierre != null) {
      cuotaActual = calcularCuotasPagadas(
        fechaGasto,
        tarjeta!.fechaCierre!,
        cuotas,
        ahora.year,
        ahora.month,
      );
      
      final mesInicioCuotas = calcularMesInicioCuotas(fechaGasto, tarjeta.fechaCierre!);
      ultimaCuotaDate = DateTime(mesInicioCuotas.year, mesInicioCuotas.month + cuotas - 1);
    } else {
      final mesesTranscurridos =
          (ahora.year - fechaGasto.year) * 12 +
          (ahora.month - fechaGasto.month);
      cuotaActual = mesesTranscurridos.clamp(0, cuotas);
      ultimaCuotaDate = DateTime(fechaGasto.year, fechaGasto.month + cuotas - 1, fechaGasto.day);
    }
    
    return CuotaInfo(
      cuotaActual: cuotaActual,
      totalCuotas: cuotas,
      valorCuota: valorCuota,
      fechaUltima: ultimaCuotaDate,
      esRecurrente: false,
      esContado: false,
    );
  }
  /// Calcula el mes/año de resumen basado en la fecha del gasto y la fecha de cierre de la tarjeta.
  /// 
  /// Ejemplo: Tarjeta cierra día 3
  /// - Compra el 9 de julio → Resumen julio
  /// - Compra el 11 de julio → Resumen agosto
  /// 
  /// Ejemplo: Tarjeta cierra día 1 (especial)
  /// - Compra cualquier día → siempre pasa al mes siguiente
  static DateTime calcularMesResumen(DateTime fechaGasto, int fechaCierre) {
    // Si el cierre es día 1, siempre pasa al mes siguiente
    if (fechaCierre == 1) {
      final mesSiguiente = fechaGasto.month + 1;
      final anioSiguiente = fechaGasto.year + (mesSiguiente > 12 ? 1 : 0);
      return DateTime(anioSiguiente, mesSiguiente > 12 ? 1 : mesSiguiente);
    }
    
    // Para cierre día 2+, usar lógica normal
    if (fechaGasto.day <= fechaCierre) {
      // El gasto entra en el resumen del mes actual
      return DateTime(fechaGasto.year, fechaGasto.month);
    } else {
      // El gasto pasa al resumen del mes siguiente
      final mesSiguiente = fechaGasto.month + 1;
      final anioSiguiente = fechaGasto.year + (mesSiguiente > 12 ? 1 : 0);
      return DateTime(anioSiguiente, mesSiguiente > 12 ? 1 : mesSiguiente);
    }
  }

  /// Calcula el mes/año de inicio de cuotas (mes de RESUMEN).
  /// 
  /// Ejemplo: Tarjeta cierra día 3
  /// - Compra el 3 de octubre (antes del cierre) → Resumen octubre → Primera cuota en octubre
  /// - Compra el 15 de octubre (después del cierre) → Resumen noviembre → Primera cuota en noviembre
  static DateTime calcularMesInicioCuotas(DateTime fechaGasto, int fechaCierre) {
    // La primera cuota es en el mes de RESUMEN
    return calcularMesResumen(fechaGasto, fechaCierre);
  }

  /// Calcula cuántas cuotas han sido pagadas hasta el mes/año seleccionado.
  /// 
  /// [fechaGasto] - Fecha de la compra
  /// [fechaCierre] - Día de cierre de la tarjeta (1-31)
  /// [totalCuotas] - Número total de cuotas
  /// [anioActual] - Año del mes seleccionado
  /// [mesActual] - Mes seleccionado (1-12)
  static int calcularCuotasPagadas(
    DateTime fechaGasto,
    int fechaCierre,
    int totalCuotas,
    int anioActual,
    int mesActual,
  ) {
    // La primera cuota es en el mes de RESUMEN
    final mesInicioCuotas = calcularMesInicioCuotas(fechaGasto, fechaCierre);
    
    // Calcular meses transcurridos desde el mes de resumen hasta el mes actual
    int mesesTranscurridos = (anioActual - mesInicioCuotas.year) * 12 + 
                            (mesActual - mesInicioCuotas.month);
    
    // Retornar las cuotas pagadas (mínimo 0, máximo totalCuotas)
    if (mesesTranscurridos < 0) return 0;
    if (mesesTranscurridos >= totalCuotas) return totalCuotas;
    return mesesTranscurridos + 1; // +1 porque la primera cuota se cuenta como pagada
  }

  /// Calcula el número de cuota actual (1-based) para el mes/año seleccionado.
  /// 
  /// Retorna 0 si la primera cuota aún no llega, o null si ya se pagaron todas.
  static int? calcularCuotaActual(
    DateTime fechaGasto,
    int fechaCierre,
    int totalCuotas,
    int anioActual,
    int mesActual,
  ) {
    // La primera cuota es en el mes de RESUMEN
    final mesInicioCuotas = calcularMesInicioCuotas(fechaGasto, fechaCierre);
    
    // Calcular meses transcurridos desde el mes de resumen hasta el mes actual
    int mesesTranscurridos = (anioActual - mesInicioCuotas.year) * 12 + 
                            (mesActual - mesInicioCuotas.month);
    
    // Si aún no llega la primera cuota
    if (mesesTranscurridos < 0) return 0;
    
    // Si ya se pagaron todas las cuotas
    if (mesesTranscurridos >= totalCuotas) return null;
    
    // Retornar la cuota actual (1-based)
    return mesesTranscurridos + 1;
  }

  /// Determina si un gasto debe aparecer en el mes/año seleccionado.
  /// 
  /// Para gastos de contado: aparece en el mes de RESUMEN.
  /// Para gastos en cuotas: aparece desde el mes de RESUMEN (primera cuota).
  static bool debeAparecerEnMes(
    DateTime fechaGasto,
    int? fechaCierre,
    int? totalCuotas,
    int anioSeleccionado,
    int mesSeleccionado,
  ) {
    // Si no tiene fecha de cierre, usar lógica simple (mes calendario)
    if (fechaCierre == null) {
      return fechaGasto.year == anioSeleccionado && fechaGasto.month == mesSeleccionado;
    }

    final mesResumen = calcularMesResumen(fechaGasto, fechaCierre);
    
    // Si no tiene cuotas (contado), debe aparecer en el mes de resumen
    if (totalCuotas == null || totalCuotas <= 0) {
      return mesResumen.year == anioSeleccionado && mesResumen.month == mesSeleccionado;
    }
    
    // Las cuotas aparecen desde el mes de RESUMEN (primera cuota)
    final mesInicioCuotas = calcularMesInicioCuotas(fechaGasto, fechaCierre);
    
    // Calcular meses transcurridos desde el mes de resumen
    int mesesTranscurridos = (anioSeleccionado - mesInicioCuotas.year) * 12 + 
                            (mesSeleccionado - mesInicioCuotas.month);
    
    // El gasto aparece si:
    // - Ya pasaron meses desde el resumen (mesesTranscurridos >= 0)
    // - Aún quedan cuotas por pagar (mesesTranscurridos < totalCuotas)
    return mesesTranscurridos >= 0 && mesesTranscurridos < totalCuotas;
  }
}
