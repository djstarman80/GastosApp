import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  final Widget child;

  const AppDrawer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GastosApp'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Inicio',
            onPressed: () => context.go('/home'),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Resumen',
            onPressed: () => context.go('/summary'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () => context.go('/backup'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'GastosApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.home,
              title: 'Inicio',
              route: '/home',
            ),
            _DrawerItem(
              icon: Icons.pie_chart,
              title: 'Resumen',
              route: '/summary',
            ),
            _DrawerItem(
              icon: Icons.settings,
              title: 'Configuración / Backup',
              route: '/backup',
            ),
            _DrawerItem(
              icon: Icons.calendar_month,
              title: 'Mensual',
              route: '/monthly_statement',
            ),
            _DrawerItem(
              icon: Icons.people,
              title: 'Administrar Usuarios',
              route: '/user_management',
            ),
            _DrawerItem(
              icon: Icons.credit_card,
              title: 'Administrar Tarjetas',
              route: '/card_management',
            ),
            _DrawerItem(
              icon: Icons.receipt_long,
              title: 'Administrar Gastos',
              route: '/expense_management',
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.info,
              title: 'Acerca De',
              route: '/about',
            ),
            _DrawerItem(
              icon: Icons.menu_book,
              title: 'Manual de Uso',
              route: '/manual',
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isSelected = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
