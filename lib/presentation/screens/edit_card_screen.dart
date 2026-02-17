import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../../data/models/models.dart';

class EditCardScreen extends ConsumerStatefulWidget {
  final int tarjetaId;

  const EditCardScreen({super.key, required this.tarjetaId});

  @override
  ConsumerState<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends ConsumerState<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _limiteController = TextEditingController();
  
  String _tipo = 'credito';
  String _nombreTarjeta = 'Visa';
  String _color = '#2196F3';
  int? _selectedUsuarioId;
  int _fechaCierre = 1;
  bool _isLoading = true;

  final List<String> _nombrees = ['Visa', 'Mastercard', 'American Express', 'Otra'];
  final List<String> _colores = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0', '#795548'];

  @override
  void initState() {
    super.initState();
    _loadTarjeta();
  }

  Future<void> _loadTarjeta() async {
    final tarjeta = await ref.read(tarjetaRepositoryProvider).getById(widget.tarjetaId);
    _nombreController.text = tarjeta.nombre;
    _limiteController.text = tarjeta.limite?.toString() ?? '';
    _tipo = tarjeta.tipo;
    _nombreTarjeta = tarjeta.nombreTarjeta;
    _color = tarjeta.color;
    _selectedUsuarioId = tarjeta.usuarioId;
    _fechaCierre = tarjeta.fechaCierre ?? 1;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _limiteController.dispose();
    super.dispose();
  }

  Future<void> _updateTarjeta() async {
    final bloqueoEdicion = ref.read(bloqueoEdicionProvider);
    if (bloqueoEdicion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edición bloqueada. Desactiva el bloqueo en Configuración para editar.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final tarjeta = await ref.read(tarjetaRepositoryProvider).getById(widget.tarjetaId);
    final updatedTarjeta = tarjeta.copyWith(
      nombre: _nombreController.text,
      banco: '', // Se quita el campo banco
      tipo: _tipo,
      nombreTarjeta: _nombreTarjeta,
      color: _color,
      usuarioId: _selectedUsuarioId,
      limite: _tipo == 'credito' ? double.tryParse(_limiteController.text) : null,
      fechaCierre: _tipo == 'credito' ? _fechaCierre : null,
    );

    await ref.read(tarjetaProvider.notifier).updateTarjeta(updatedTarjeta);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarjeta actualizada')));
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteTarjeta() async {
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
        title: const Text('Eliminar Tarjeta'),
        content: const Text('¿Seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(tarjetaProvider.notifier).deleteTarjeta(widget.tarjetaId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tarjeta'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        actions: [IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _deleteTarjeta)],
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
            TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null),
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
            ElevatedButton(onPressed: _updateTarjeta, child: const Text('Actualizar')),
          ],
        ),
      ),
    );
  }
}
