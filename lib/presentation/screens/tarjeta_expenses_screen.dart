import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/cuota_utils.dart';
import '../../data/models/models.dart';

class TarjetaExpensesScreen extends ConsumerWidget {
  final int tarjetaId;
  final int? year;
  final int? month;

  const TarjetaExpensesScreen({
    super.key, 
    required this.tarjetaId,
    this.year,
    this.month,
  });

  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  List<Map<String, dynamic>> _getGastosDelMes(List<dynamic> gastos, List<Tarjeta> tarjetas, int selectedYear, int selectedMonth) {
    final result = <Map<String, dynamic>>[];
    
    for (final g in gastos) {
      final fechaGasto = DateTime.fromMillisecondsSinceEpoch(g.fecha as int);
      double montoMostrar = g.monto;
      
      final tarjeta = tarjetas.where((t) => t.id == g.tarjetaId).firstOrNull;
      final fechaCierre = tarjeta?.fechaCierre;
      
      if (g.esRecurrente) {
        final mesResumen = fechaCierre != null 
            ? CuotaUtils.calcularMesResumen(fechaGasto, fechaCierre)
            : fechaGasto;
            
        if (selectedYear < mesResumen.year || 
            (selectedYear == mesResumen.year && selectedMonth >= mesResumen.month)) {
          montoMostrar = g.monto;
          result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': true});
        }
      } else if (g.cuotas != null && g.cuotas! > 0) {
        if (fechaCierre != null) {
          if (CuotaUtils.debeAparecerEnMes(
            fechaGasto, 
            fechaCierre, 
            g.cuotas, 
            selectedYear, 
            selectedMonth
          )) {
            montoMostrar = g.monto / g.cuotas!;
            result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': false});
          }
        } else {
          final mesInicio = fechaGasto.month;
          final anioInicio = fechaGasto.year;
          int mesesTranscurridos = (selectedYear - anioInicio) * 12 + (selectedMonth - mesInicio);
          if (mesesTranscurridos >= 0 && mesesTranscurridos < g.cuotas!) {
            montoMostrar = g.monto / g.cuotas!;
            result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': false});
          }
        }
      } else {
        if (fechaCierre != null) {
          final mesResumen = CuotaUtils.calcularMesResumen(fechaGasto, fechaCierre);
          if (mesResumen.year == selectedYear && mesResumen.month == selectedMonth) {
            montoMostrar = g.monto;
            result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': false});
          }
        } else {
          if (fechaGasto.year == selectedYear && fechaGasto.month == selectedMonth) {
            montoMostrar = g.monto;
            result.add({'gasto': g, 'monto': montoMostrar, 'esRecurrente': false});
          }
        }
      }
    }
    
    return result;
  }

  int _calcularCuotasPagadas(int fecha, int? cuotas, int? fechaCierre, int currentYear, int currentMonth) {
    if (cuotas == null || cuotas == 0) return 0;
    
    final fechaGasto = DateTime.fromMillisecondsSinceEpoch(fecha);
    
    if (fechaCierre != null) {
      return CuotaUtils.calcularCuotasPagadas(
        fechaGasto, 
        fechaCierre, 
        cuotas, 
        currentYear, 
        currentMonth
      );
    } else {
      final mesesTranscurridos = 
        (currentYear - fechaGasto.year) * 12 + 
        (currentMonth - fechaGasto.month);
      
      return mesesTranscurridos.clamp(0, cuotas);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastoState = ref.watch(gastoProvider);
    final tarjetaState = ref.watch(tarjetaProvider);
    final usuarioState = ref.watch(usuarioProvider);

    final selectedYear = year ?? DateTime.now().year;
    final selectedMonth = month ?? DateTime.now().month;

    final tarjeta = tarjetaState.tarjetas.where((t) => t.id == tarjetaId).firstOrNull;

    final gastosDeTarjeta = gastoState.gastos.where((g) => g.tarjetaId == tarjetaId).toList();
    final monthGastos = _getGastosDelMes(gastosDeTarjeta, tarjetaState.tarjetas, selectedYear, selectedMonth);

    final totalMes = monthGastos.fold(0.0, (sum, g) => sum + (g['monto'] as double));

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gastos con ${tarjeta?.nombre ?? 'Tarjeta'}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: monthGastos.isEmpty
          ? const Center(child: Text('No hay gastos este mes'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: monthGastos.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    color: Theme.of(context).colorScheme.primary,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Total ${_meses[selectedMonth - 1]} $selectedYear',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(totalMes),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final g = monthGastos[index - 1];
                final gasto = g['gasto'];
                final usuario = usuarioState.usuarios.where((u) => u.id == gasto.usuarioId).firstOrNull;
                
                final cuotasPagadas = _calcularCuotasPagadas(
                  gasto.fecha, 
                  gasto.cuotas, 
                  tarjeta?.fechaCierre,
                  selectedYear,
                  selectedMonth
                );
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                gasto.descripcion,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (gasto.esRecurrente)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Recurrente',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          usuario?.nombre ?? 'Usuario ${gasto.usuarioId}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormatter.format(g['monto'] as double),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (gasto.cuotas != null && gasto.cuotas! > 0)
                              Text(
                                'Cuota: $cuotasPagadas/${gasto.cuotas}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
