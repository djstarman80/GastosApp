import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  int? _selectedUsuarioId;
  int? _selectedTarjetaId;
  DateTime _fecha = DateTime.now();
  int? _cuotas;
  bool _esRecurrente = false;
  bool _pagado = false;

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _fecha = picked;
      });
    }
  }

  Future<void> _saveGasto() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUsuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un usuario')),
      );
      return;
    }
    if (_selectedTarjetaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una tarjeta')),
      );
      return;
    }

    final monto = double.tryParse(_montoController.text) ?? 0;
    
    await ref.read(gastoProvider.notifier).addGasto(
      monto: monto,
      descripcion: _descripcionController.text,
      tarjetaId: _selectedTarjetaId!,
      usuarioId: _selectedUsuarioId!,
      fecha: _fecha.millisecondsSinceEpoch,
      cuotas: _cuotas,
      esRecurrente: _esRecurrente,
      pagado: _pagado,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto agregado exitosamente')),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioState = ref.watch(usuarioProvider);
    final tarjetaState = ref.watch(tarjetaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Gasto'),
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
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el monto';
                }
                if (double.tryParse(value) == null) {
                  return 'Monto inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese la descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedUsuarioId,
              decoration: const InputDecoration(
                labelText: 'Usuario',
              ),
              items: usuarioState.usuarios.map((u) {
                return DropdownMenuItem(
                  value: u.id,
                  child: Text(u.nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUsuarioId = value;
                  _selectedTarjetaId = null;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedUsuarioId != null)
              DropdownButtonFormField<int>(
                value: _selectedTarjetaId,
                decoration: const InputDecoration(
                  labelText: 'Tarjeta',
                ),
                items: tarjetaState.tarjetas
                    .where((t) => t.usuarioId == _selectedUsuarioId)
                    .map((t) {
                  return DropdownMenuItem(
                    value: t.id,
                    child: Text('${t.nombre} - ${t.banco}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTarjetaId = value;
                  });
                },
              ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            if (_selectedTarjetaId != null && 
                tarjetaState.tarjetas.any((t) => t.id == _selectedTarjetaId && t.tipo == 'debito'))
              SwitchListTile(
                title: const Text('Es recurrente'),
                value: _esRecurrente,
                onChanged: (value) {
                  setState(() {
                    _esRecurrente = value;
                  });
                },
              ),
            if (_selectedTarjetaId != null && 
                tarjetaState.tarjetas.any((t) => t.id == _selectedTarjetaId && t.tipo == 'credito'))
              DropdownButtonFormField<int>(
                value: _cuotas,
                decoration: const InputDecoration(
                  labelText: 'Cuotas',
                ),
                items: List.generate(24, (i) => i + 1).map((n) {
                  return DropdownMenuItem(
                    value: n,
                    child: Text('$n cuotas'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _cuotas = value;
                  });
                },
              ),
            SwitchListTile(
              title: const Text('Pagado'),
              value: _pagado,
              onChanged: (value) {
                setState(() {
                  _pagado = value;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveGasto,
              child: const Text('Guardar Gasto'),
            ),
          ],
        ),
      ),
    );
  }
}
