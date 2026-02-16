import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class EditUserScreen extends ConsumerStatefulWidget {
  final int usuarioId;

  const EditUserScreen({super.key, required this.usuarioId});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsuario();
  }

  Future<void> _loadUsuario() async {
    final usuario = await ref.read(usuarioRepositoryProvider).getById(widget.usuarioId);
    _nombreController.text = usuario.nombre;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _updateUsuario() async {
    final bloqueoEdicion = ref.read(bloqueoEdicionProvider);
    if (bloqueoEdicion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edición bloqueada. Desactiva el bloqueo en Configuración para editar.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final usuario = await ref.read(usuarioRepositoryProvider).getById(widget.usuarioId);
    final updatedUsuario = usuario.copyWith(nombre: _nombreController.text);

    await ref.read(usuarioProvider.notifier).updateUsuario(updatedUsuario);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final bloqueoEdicion = ref.read(bloqueoEdicionProvider);
              if (bloqueoEdicion) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edición bloqueada. Desactiva el bloqueo en Configuración para editar.')),
                );
                return;
              }

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar Usuario'),
                  content: const Text('¿Estás seguro?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(usuarioProvider.notifier).deleteUsuario(widget.usuarioId);
                if (mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateUsuario,
              child: const Text('Actualizar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
