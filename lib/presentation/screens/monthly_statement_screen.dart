import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/cuota_utils.dart';
import '../../data/models/models.dart';

class MonthlyStatementScreen extends ConsumerStatefulWidget {
  const MonthlyStatementScreen({super.key});

  @override
  ConsumerState<MonthlyStatementScreen> createState() => _MonthlyStatementScreenState();
}

class _MonthlyStatementScreenState extends ConsumerState<MonthlyStatementScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final gastoState = ref.watch(gastoProvider);
    final tarjetaState = ref.watch(tarjetaProvider);
    final usuarioState = ref.watch(usuarioProvider);

    // Filtrar gastos según su mes de resumen (considerando fecha de cierre)
    final monthGastos = gastoState.gastos.where((g) {
      final fechaGasto = DateTime.fromMillisecondsSinceEpoch(g.fecha);
      final tarjeta = tarjetaState.tarjetas.where((t) => t.id == g.tarjetaId).firstOrNull;
      
      if (tarjeta?.fechaCierre != null) {
        // Usar lógica de fecha de cierre para determinar el mes de resumen
        final mesResumen = CuotaUtils.calcularMesResumen(fechaGasto, tarjeta!.fechaCierre!);
        return mesResumen.year == _selectedYear && mesResumen.month == _selectedMonth;
      } else {
        // Fallback: usar mes calendario si no hay fecha de cierre
        return fechaGasto.year == _selectedYear && fechaGasto.month == _selectedMonth;
      }
    }).toList();

    final total = monthGastos.fold(0.0, (sum, g) => sum + g.monto);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado Mensual'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  dropdownColor: Theme.of(context).colorScheme.primary,
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox(),
                  items: List.generate(12, (i) => i + 1).map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(
                        DateFormat('MMMM').format(DateTime(2024, m)),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: _selectedYear,
                  dropdownColor: Theme.of(context).colorScheme.primary,
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox(),
                  items: List.generate(10, (i) => DateTime.now().year - 5 + i).map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text('$y', style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedYear = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Center(
              child: Text(
                'Total: ${CurrencyFormatter.format(total)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: monthGastos.isEmpty
                ? const Center(child: Text('No hay gastos este mes'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: monthGastos.length,
                    itemBuilder: (context, index) {
                      final gasto = monthGastos[index];
                      final tarjeta = tarjetaState.tarjetas
                          .where((t) => t.id == gasto.tarjetaId)
                          .firstOrNull;
                      final usuario = usuarioState.usuarios
                          .where((u) => u.id == gasto.usuarioId)
                          .firstOrNull;

                      return Card(
                        child: ListTile(
                          title: Text(gasto.descripcion),
                          subtitle: Text(
                            '${tarjeta?.nombre ?? 'N/A'} - ${usuario?.nombre ?? 'N/A'}',
                          ),
                          trailing: Text(
                            CurrencyFormatter.format(gasto.monto),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
