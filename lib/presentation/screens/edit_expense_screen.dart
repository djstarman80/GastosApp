import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final int gastoId;

  const EditExpenseScreen({super.key, required this.gastoId});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  int? _selectedUsuarioId;
  int? _selectedTarjetaId;
  DateTime _fecha = DateTime.now();
  int? _cuotas;
  bool _esRecurrente = false;
  bool _pagado = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGasto();
  }

  Future<void> _loadGasto() async {
    final gasto = await ref.read(gastoRepositoryProvider).getById(widget.gastoId);
    _montoController.text = gasto.monto.toString();
    _descripcionController.text = gasto.descripcion;
    _selectedUsuarioId = gasto.usuarioId;
    _selectedTarjetaId = gasto.tarjetaId;
    _fecha = DateTime.fromMillisecondsSinceEpoch(gasto.fecha);
    _cuotas = gasto.cuotas;
    _esRecurrente = gasto.esRecurrente;
    _pagado = gasto.pagado;
    setState(() {
      _isLoading = false;
    });
  }

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

  Future<void> _updateGasto() async {
    final bloqueoEdicion = ref.read(bloqueoEdicionProvider);
    if (bloqueoEdicion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edición bloqueada. Desactiva el bloqueo en Configuración para editar.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final gasto = await ref.read(gastoRepositoryProvider).getById(widget.gastoId);
    final updatedGasto = gasto.copyWith(
      monto: double.tryParse(_montoController.text) ?? gasto.monto,
      descripcion: _descripcionController.text,
      tarjetaId: _selectedTarjetaId,
      usuarioId: _selectedUsuarioId,
      fecha: _fecha.millisecondsSinceEpoch,
      cuotas: _cuotas,
      esRecurrente: _esRecurrente,
      pagado: _pagado,
    );

    await ref.read(gastoProvider.notifier).updateGasto(updatedGasto);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto actualizado')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteGasto() async {
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
        title: const Text('Eliminar Gasto'),
        content: const Text('¿Estás seguro de eliminar este gasto?'),
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
      await ref.read(gastoProvider.notifier).deleteGasto(widget.gastoId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioState = ref.watch(usuarioProvider);
    final tarjetaState = ref.watch(tarjetaProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Gasto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteGasto,
          ),
        ],
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
                if (value == null || value.isEmpty) return 'Ingrese el monto';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingrese la descripción';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedUsuarioId,
              decoration: const InputDecoration(labelText: 'Usuario'),
              items: usuarioState.usuarios.map((u) {
                return DropdownMenuItem(value: u.id, child: Text(u.nombre));
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
                decoration: const InputDecoration(labelText: 'Tarjeta'),
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
              onPressed: _updateGasto,
              child: const Text('Actualizar Gasto'),
            ),
          ],
        ),
      ),
    );
  }
}
