import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/add_card_screen.dart';
import '../screens/add_user_screen.dart';
import '../screens/summary_screen.dart';
import '../screens/backup_screen.dart';
import '../screens/card_management_screen.dart';
import '../screens/user_management_screen.dart';
import '../screens/expense_management_screen.dart';
import '../screens/monthly_statement_screen.dart';
import '../screens/edit_expense_screen.dart';
import '../screens/edit_card_screen.dart';
import '../screens/edit_user_screen.dart';
import '../screens/about_screen.dart';
import '../screens/user_manual_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/more_screen.dart';
import '../screens/user_expenses_screen.dart';
import '../screens/tarjeta_expenses_screen.dart';
import '../widgets/main_navigation.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRoutes = [
  GoRoute(
    path: '/onboarding',
    builder: (context, state) => const OnboardingScreen(),
  ),
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    builder: (context, state, child) => MainNavigation(child: child),
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add_expense',
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: '/add_card',
        builder: (context, state) => const AddCardScreen(),
      ),
      GoRoute(
        path: '/add_user',
        builder: (context, state) => const AddUserScreen(),
      ),
      GoRoute(
        path: '/summary',
        builder: (context, state) => const SummaryScreen(),
      ),
      GoRoute(
        path: '/user_expenses/:userId',
        builder: (context, state) {
          final userId = int.tryParse(state.pathParameters['userId'] ?? '0') ?? 0;
          final year = int.tryParse(state.uri.queryParameters['year'] ?? '');
          final month = int.tryParse(state.uri.queryParameters['month'] ?? '');
          return UserExpensesScreen(
            usuarioId: userId,
            year: year,
            month: month,
          );
        },
      ),
      GoRoute(
        path: '/tarjeta_expenses/:tarjetaId',
        builder: (context, state) {
          final tarjetaId = int.tryParse(state.pathParameters['tarjetaId'] ?? '0') ?? 0;
          final year = int.tryParse(state.uri.queryParameters['year'] ?? '');
          final month = int.tryParse(state.uri.queryParameters['month'] ?? '');
          return TarjetaExpensesScreen(
            tarjetaId: tarjetaId,
            year: year,
            month: month,
          );
        },
      ),
      GoRoute(
        path: '/backup',
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: '/card_management',
        builder: (context, state) => const CardManagementScreen(),
      ),
      GoRoute(
        path: '/user_management',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/expense_management',
        builder: (context, state) => const ExpenseManagementScreen(),
      ),
      GoRoute(
        path: '/monthly_statement',
        builder: (context, state) => const MonthlyStatementScreen(),
      ),
      GoRoute(
        path: '/more',
        builder: (context, state) => const MoreScreen(),
      ),
      GoRoute(
        path: '/edit_expense/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return EditExpenseScreen(gastoId: id);
        },
      ),
      GoRoute(
        path: '/edit_card/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return EditCardScreen(tarjetaId: id);
        },
      ),
      GoRoute(
        path: '/edit_user/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return EditUserScreen(usuarioId: id);
        },
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/manual',
        builder: (context, state) => const UserManualScreen(),
      ),
    ],
  ),
];

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: appRoutes,
);
