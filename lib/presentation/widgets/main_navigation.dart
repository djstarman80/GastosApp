import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final route = GoRouterState.of(context).matchedLocation;
    if (route == '/home') return 0;
    if (route == '/summary') return 1;
    if (route == '/add_expense' || route == '/add_card' || route == '/add_user') return 2;
    if (route == '/expense_management') return 3;
    return 4; // más
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/summary');
              break;
            case 2:
              _showAddMenu(context);
              break;
            case 3:
              context.go('/expense_management');
              break;
            case 4:
              context.go('/more');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Agregar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Gastos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Más',
          ),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Agregar Gasto'),
              onTap: () {
                Navigator.pop(context);
                context.go('/add_expense');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Agregar Tarjeta'),
              onTap: () {
                Navigator.pop(context);
                context.go('/add_card');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Agregar Usuario'),
              onTap: () {
                Navigator.pop(context);
                context.go('/add_user');
              },
            ),
          ],
        ),
      ),
    );
  }
}
