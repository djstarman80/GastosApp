import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioState = ref.watch(usuarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Usuarios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: usuarioState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : usuarioState.usuarios.isEmpty
              ? const Center(child: Text('No hay usuarios registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: usuarioState.usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarioState.usuarios[index];

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(usuario.nombre[0].toUpperCase()),
                        ),
                        title: Text(usuario.nombre),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => context.push('/edit_user/${usuario.id}'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar Usuario'),
                                    content: Text(
                                      '¿Estás seguro de eliminar a ${usuario.nombre}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ref
                                              .read(usuarioProvider.notifier)
                                              .deleteUsuario(usuario.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Eliminar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add_user'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
