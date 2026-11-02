import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

void main() {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => GenesisShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
          GoRoute(path: '/projects', builder: (context, state) => const ModulePage(title: 'Projetos')),
          GoRoute(path: '/clients', builder: (context, state) => const ModulePage(title: 'Clientes')),
          GoRoute(path: '/agenda', builder: (context, state) => const ModulePage(title: 'Agenda')),
          GoRoute(path: '/finance', builder: (context, state) => const ModulePage(title: 'Financeiro')),
        ],
      ),
    ],
  );

  GetIt.I.registerSingleton<GoRouter>(router);
  runApp(const GenesisApp());
}

class GenesisApp extends StatelessWidget {
  const GenesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema Genesis',
      debugShowCheckedModeBanner: false,
      routerConfig: GetIt.I<GoRouter>(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D4AFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class GenesisShell extends StatelessWidget {
  const GenesisShell({
    required this.currentPath,
    required this.child,
    super.key,
  });

  final String currentPath;
  final Widget child;

  static const _destinations = [
    (label: 'Visão geral', icon: Icons.dashboard_outlined, path: '/'),
    (label: 'Projetos', icon: Icons.work_outline, path: '/projects'),
    (label: 'Clientes', icon: Icons.people_outline, path: '/clients'),
    (label: 'Agenda', icon: Icons.calendar_month_outlined, path: '/agenda'),
    (label: 'Financeiro', icon: Icons.account_balance_wallet_outlined, path: '/finance'),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _destinations.indexWhere((item) => item.path == currentPath);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            onDestinationSelected: (index) => context.go(_destinations[index].path),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF6D4AFF),
                child: Icon(Icons.layers_outlined, color: Colors.white),
              ),
            ),
            destinations: [
              for (final item in _destinations)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text('Visão geral', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Acompanhe seus projetos, compromissos e movimentações em um só lugar.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              SummaryCard(label: 'Projetos em andamento', value: '0', icon: Icons.work_outline),
              SummaryCard(label: 'Clientes ativos', value: '0', icon: Icons.people_outline),
              SummaryCard(label: 'A receber', value: 'R\$ 0,00', icon: Icons.south_west),
              SummaryCard(label: 'Despesas do mês', value: 'R\$ 0,00', icon: Icons.north_east),
            ],
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Próximos passos', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const Text('Cadastre um cliente e crie seu primeiro projeto para começar.'),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => context.go('/projects'),
                    icon: const Icon(Icons.add),
                    label: const Text('Abrir projetos'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF6D4AFF)),
              const SizedBox(height: 16),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class ModulePage extends StatelessWidget {
  const ModulePage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Módulo preparado para implementação.'),
        ],
      ),
    );
  }
}
