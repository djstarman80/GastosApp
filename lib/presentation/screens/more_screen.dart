import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../widgets/export_pdf_dialog.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Más'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.people,
            title: 'Administrar Usuarios',
            subtitle: 'Gestionar usuarios de la app',
            onTap: () => context.go('/user_management'),
          ),
          _MenuItem(
            icon: Icons.credit_card,
            title: 'Administrar Tarjetas',
            subtitle: 'Gestionar tarjetas de crédito/débito',
            onTap: () => context.go('/card_management'),
          ),
          _MenuItem(
            icon: Icons.picture_as_pdf,
            title: 'Exportar a PDF',
            subtitle: 'Generar resumen de gastos en PDF',
            onTap: () => _showExportPdfDialog(context),
          ),
          const Divider(),
          _MenuItem(
            icon: Icons.settings,
            title: 'Configuración / Backup',
            subtitle: 'Exportar e importar datos',
            onTap: () => context.go('/backup'),
          ),
          SwitchListTile(
            secondary: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.play_circle_outline, color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('Pantalla de Bienvenida'),
            subtitle: const Text('Mostrar al iniciar la app'),
            value: !settingsState.onboardingCompleted,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setOnboardingCompleted(!value);
              if (value) {
                context.go('/onboarding');
              } else {
                context.go('/home');
              }
            },
          ),
          SwitchListTile(
            secondary: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.1),
              child: const Icon(Icons.lock, color: Colors.red),
            ),
            title: const Text('Bloquear Edición'),
            subtitle: const Text('Evitar editar gastos, tarjetas y usuarios'),
            value: settingsState.bloqueoEdicion,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setBloqueoEdicion(value);
            },
          ),
          const Divider(),
          _MenuItem(
            icon: Icons.info,
            title: 'Acerca De',
            subtitle: 'Información de la aplicación',
            onTap: () => context.go('/about'),
          ),
          _MenuItem(
            icon: Icons.menu_book,
            title: 'Manual de Uso',
            subtitle: 'Guía de la aplicación',
            onTap: () => context.go('/manual'),
          ),
        ],
      ),
    );
  }

  void _showExportPdfDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ExportPdfDialog(),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
