import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _limiteController = TextEditingController();
  
  String _tipo = 'credito';
  String _nombreTarjeta = 'Visa';
  String _color = '#2196F3';
  int _selectedUsuarioId = 0;
  int _fechaCierre = 1;

  final List<String> _nombrees = ['Visa', 'Mastercard', 'American Express', 'Otra'];
  final List<String> _colores = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0', '#795548'];

  @override
  void dispose() {
    _nombreController.dispose();
    _limiteController.dispose();
    super.dispose();
  }

  Future<void> _saveTarjeta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUsuarioId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un usuario')),
      );
      return;
    }

    final limite = _tipo == 'credito' ? double.tryParse(_limiteController.text) : null;

    await ref.read(tarjetaProvider.notifier).addTarjeta(
      tipo: _tipo,
      nombre: _nombreController.text,
      banco: '', // Se quita el campo banco
      nombreTarjeta: _nombreTarjeta,
      color: _color,
      limite: limite,
      usuarioId: _selectedUsuarioId,
      fechaCierre: _tipo == 'credito' ? _fechaCierre : null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarjeta agregada exitosamente')),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioState = ref.watch(usuarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Tarjeta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo de Tarjeta'),
              items: const [
                DropdownMenuItem(value: 'credito', child: Text('Crédito')),
                DropdownMenuItem(value: 'debito', child: Text('Débito')),
              ],
              onChanged: (value) => setState(() => _tipo = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre de la Tarjeta'),
              validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _nombreTarjeta,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: _nombrees.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (value) => setState(() => _nombreTarjeta = value!),
            ),
            const SizedBox(height: 16),
            if (_tipo == 'credito') ...[
              DropdownButtonFormField<int>(
                value: _fechaCierre,
                decoration: const InputDecoration(
                  labelText: 'Día de Cierre',
                  helperText: 'Día del mes (1-31)',
                ),
                items: List.generate(31, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text('$d'))).toList(),
                onChanged: (value) => setState(() => _fechaCierre = value ?? 1),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limiteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Límite', prefixText: '\$ '),
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<int>(
              value: _selectedUsuarioId == 0 ? null : _selectedUsuarioId,
              decoration: const InputDecoration(labelText: 'Usuario'),
              items: usuarioState.usuarios.map((u) => DropdownMenuItem(value: u.id, child: Text(u.nombre))).toList(),
              onChanged: (value) => setState(() => _selectedUsuarioId = value ?? 0),
              validator: (value) => value == null ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            const Text('Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colores.map((c) {
                final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _color == c ? Border.all(color: Colors.black, width: 3) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTarjeta,
              child: const Text('Guardar Tarjeta'),
            ),
          ],
        ),
      ),
    );
  }
}
