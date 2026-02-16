import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual de Uso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ManualSection(
            icon: Icons.person_add,
            title: '1. Crear Usuarios',
            content: 'Primero, crea los usuarios que usarán la app. '
                'Cada usuario puede tener sus propias tarjetas y gastos.',
          ),
          _ManualSection(
            icon: Icons.credit_card,
            title: '2. Agregar Tarjetas',
            content: 'Añade las tarjetas de crédito o débito de cada usuario. '
                'Puedes especificar el límite de crédito y el día de cierre.',
          ),
          _ManualSection(
            icon: Icons.add_circle,
            title: '3. Registrar Gastos',
            content: 'Registra cada gasto indicando monto, descripción, '
                'tarjeta utilizada y usuario. Puedes marcar como recurrente.',
          ),
          _ManualSection(
            icon: Icons.pie_chart,
            title: '4. Ver Resúmenes',
            content: 'Consulta estadísticas de gastos por tarjeta, usuario o período.',
          ),
          _ManualSection(
            icon: Icons.calendar_month,
            title: '5. Estados Mensuales',
            content: 'Visualiza el detalle de gastos de cada mes.',
          ),
          _ManualSection(
            icon: Icons.settings,
            title: '6. Configuración',
            content: 'Activa el modo oscuro y gestiona tus datos desde el menú.',
          ),
        ],
      ),
    );
  }
}

class _ManualSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _ManualSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
