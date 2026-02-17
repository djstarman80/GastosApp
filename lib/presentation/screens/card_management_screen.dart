import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class CardManagementScreen extends ConsumerWidget {
  const CardManagementScreen({super.key});

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
    final tarjetaState = ref.watch(tarjetaProvider);
    final usuarioState = ref.watch(usuarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Tarjetas'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
      ),
      body: tarjetaState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tarjetaState.tarjetas.isEmpty
              ? const Center(child: Text('No hay tarjetas'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: tarjetaState.tarjetas.length,
                  itemBuilder: (context, index) {
                    final tarjeta = tarjetaState.tarjetas[index];
                    final usuario = usuarioState.usuarios.where((u) => u.id == tarjeta.usuarioId).firstOrNull;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _parseColor(tarjeta.color),
                          child: Text(
                            tarjeta.nombreTarjeta?.isNotEmpty == true 
                                ? tarjeta.nombreTarjeta[0] 
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(tarjeta.nombre),
                        subtitle: Text(usuario?.nombre ?? 'N/A'),
                        trailing: Text(tarjeta.tipo == 'credito' ? 'Crédito' : 'Débito'),
                        onTap: () => context.push('/edit_card/${tarjeta.id}'),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add_card'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
