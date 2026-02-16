import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _noMostrarNuevo = false;

  final List<Widget> _pages = [
    _OnboardingPage(
      icon: Icons.account_balance_wallet,
      title: 'Gestiona tus Gastos',
      description: 'Controla tus gastos de manera fácil y eficiente',
      color: Colors.green,
    ),
    _OnboardingPage(
      icon: Icons.credit_card,
      title: 'Multiple Tarjetas',
      description: 'Administra todas tus tarjetas de crédito y débito',
      color: Colors.orange,
    ),
    _OnboardingPage(
      icon: Icons.people,
      title: 'Gestión de Usuarios',
      description: 'Permite que varios miembros de la familia gestionen sus propios gastos',
      color: Colors.blue,
    ),
  ];

  Widget _buildLastPage() {
    return _OnboardingPage(
      icon: Icons.account_balance_wallet,
      title: 'GastosApp',
      description: 'Desarrollado Por Marcelo Pereyra\n\nSoporte: lm.marcelo@gmail.com',
      color: Colors.green,
      showCheckbox: true,
      noMostrarNuevo: _noMostrarNuevo,
      onCheckboxChanged: (value) {
        setState(() {
          _noMostrarNuevo = value;
        });
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    if (_noMostrarNuevo) {
      ref.read(settingsProvider.notifier).setOnboardingCompleted(true);
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length + 1,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  if (index == _pages.length) {
                    return _buildLastPage();
                  }
                  return _pages[index];
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length + 1,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Atrás'),
                    )
                  else
                    const SizedBox(),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length
                          ? 'Comenzar'
                          : 'Siguiente',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool showCheckbox;
  final bool? noMostrarNuevo;
  final ValueChanged<bool>? onCheckboxChanged;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.showCheckbox = false,
    this.noMostrarNuevo,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (showCheckbox) ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: noMostrarNuevo ?? false,
                  onChanged: (value) => onCheckboxChanged?.call(value ?? false),
                ),
                const Text('No mostrar nuevamente'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
