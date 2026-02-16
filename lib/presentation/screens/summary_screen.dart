import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../../core/utils/currency_formatter.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  Color _parseColor(String color) {
    try {
      if (color.startsWith('#')) {
        return Color(int.parse(color.replaceFirst('#', '0xFF')));
      }
      return Color(int.parse(color));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastoState = ref.watch(gastoProvider);
    final tarjetaState = ref.watch(tarjetaProvider);
    final usuarioState = ref.watch(usuarioProvider);

    final gastosPorTarjeta = <int, double>{};
    for (final gasto in gastoState.gastos) {
      gastosPorTarjeta[gasto.tarjetaId] = (gastosPorTarjeta[gasto.tarjetaId] ?? 0) + gasto.monto;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Total General', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text(CurrencyFormatter.format(gastoState.totalGastos), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${gastoState.gastos.length} gastos', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Gastos por Tarjeta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...gastosPorTarjeta.entries.map((entry) {
            final tarjeta = tarjetaState.tarjetas.where((t) => t.id == entry.key).firstOrNull;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tarjeta != null 
                      ? _parseColor(tarjeta.color) 
                      : Colors.grey,
                  child: Text(
                    tarjeta?.nombreTarjeta?.isNotEmpty == true 
                        ? tarjeta!.nombreTarjeta[0] 
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(tarjeta?.nombre ?? 'Desconocida'),
                trailing: Text(CurrencyFormatter.format(entry.value), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text('Gastos por Usuario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...usuarioState.usuarios.map((usuario) {
            final total = gastoState.gastos.where((g) => g.usuarioId == usuario.id).fold(0.0, (sum, g) => sum + g.monto);
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(usuario.nombre[0].toUpperCase())),
                title: Text(usuario.nombre),
                trailing: Text(CurrencyFormatter.format(total), style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => context.push('/user_expenses/${usuario.id}'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
