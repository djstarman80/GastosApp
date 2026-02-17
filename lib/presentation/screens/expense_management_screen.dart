import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/cuota_utils.dart';
import '../../data/models/models.dart';

class ExpenseManagementScreen extends ConsumerStatefulWidget {
  const ExpenseManagementScreen({super.key});

  @override
  ConsumerState<ExpenseManagementScreen> createState() => _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends ConsumerState<ExpenseManagementScreen> {
  int? _selectedUsuarioId;
  int? _selectedTarjetaId;

  String _getCuotaInfo(Gasto gasto, Tarjeta? tarjeta) {
    if (gasto.esRecurrente) return 'Recurrente';
    if (gasto.cuotas == null || gasto.cuotas == 0 || gasto.cuotas == 1) {
      // Para gastos de contado, mostrar el mes de resumen si hay fecha de cierre
      if (tarjeta?.fechaCierre != null) {
        final fechaGasto = DateTime.fromMillisecondsSinceEpoch(gasto.fecha);
        final mesResumen = CuotaUtils.calcularMesResumen(fechaGasto, tarjeta!.fechaCierre!);
        return 'Contado | Resumen: ${DateFormat('MM/yyyy').format(mesResumen)}';
      }
      return 'Contado';
    }
    
    final fechaGasto = DateTime.fromMillisecondsSinceEpoch(gasto.fecha);
    final ahora = DateTime.now();
    final int cuotas = gasto.cuotas!;
    final valorCuota = gasto.monto / cuotas;
    
    int cuotaActual;
    DateTime ultimaCuotaDate;
    
    if (tarjeta?.fechaCierre != null) {
      // Usar lógica de fecha de cierre
      cuotaActual = CuotaUtils.calcularCuotasPagadas(
        fechaGasto, 
        tarjeta!.fechaCierre!, 
        cuotas, 
        ahora.year, 
        ahora.month
      );
      
      // Calcular fecha de última cuota basada en fecha de cierre
      final mesInicioCuotas = CuotaUtils.calcularMesInicioCuotas(fechaGasto, tarjeta.fechaCierre!);
      ultimaCuotaDate = DateTime(mesInicioCuotas.year, mesInicioCuotas.month + cuotas - 1);
    } else {
      // Fallback: usar mes calendario
      final mesesTranscurridos = 
        (ahora.year - fechaGasto.year) * 12 + 
        (ahora.month - fechaGasto.month);
      cuotaActual = mesesTranscurridos.clamp(0, cuotas);
      ultimaCuotaDate = DateTime(fechaGasto.year, fechaGasto.month + cuotas - 1, fechaGasto.day);
    }
    
    final fechaUltima = DateFormat('MM/yyyy').format(ultimaCuotaDate);
    
    return 'Cuota $cuotaActual/$cuotas (${CurrencyFormatter.format(valorCuota)}) | Última: $fechaUltima';
  }

  @override
  Widget build(BuildContext context) {
    final gastoState = ref.watch(gastoProvider);
    final tarjetaState = ref.watch(tarjetaProvider);
    final usuarioState = ref.watch(usuarioProvider);

    final filteredGastos = gastoState.gastos.where((g) {
      if (_selectedUsuarioId != null && g.usuarioId != _selectedUsuarioId) return false;
      if (_selectedTarjetaId != null && g.tarjetaId != _selectedTarjetaId) return false;
      return true;
    }).toList();

    final tarjetasFiltradas = _selectedUsuarioId != null
        ? tarjetaState.tarjetas.where((t) => t.usuarioId == _selectedUsuarioId).toList()
        : tarjetaState.tarjetas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Gastos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _selectedUsuarioId,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ...usuarioState.usuarios.map((u) {
                        return DropdownMenuItem(
                          value: u.id,
                          child: Text(u.nombre, overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUsuarioId = value;
                        _selectedTarjetaId = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _selectedTarjetaId,
                    decoration: const InputDecoration(
                      labelText: 'Tarjeta',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...tarjetasFiltradas.map((t) {
                        return DropdownMenuItem(
                          value: t.id,
                          child: Text(t.nombre),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTarjetaId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: gastoState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredGastos.isEmpty
                    ? const Center(child: Text('No hay gastos registrados'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredGastos.length,
                        itemBuilder: (context, index) {
                          final gasto = filteredGastos[index];
                          final tarjeta = tarjetaState.tarjetas
                              .where((t) => t.id == gasto.tarjetaId)
                              .firstOrNull;
                          final usuario = usuarioState.usuarios
                              .where((u) => u.id == gasto.usuarioId)
                              .firstOrNull;

                          return Card(
                            child: ListTile(
                              title: Text(gasto.descripcion),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${tarjeta?.nombre ?? 'N/A'} - ${usuario?.nombre ?? 'N/A'} | ${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(gasto.fecha))}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                   Text(
                                    '${CurrencyFormatter.format(gasto.monto)}    ${_getCuotaInfo(gasto, tarjeta)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              onTap: () => context.push('/edit_expense/${gasto.id}'),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add_expense'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
