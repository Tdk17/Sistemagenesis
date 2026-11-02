import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_genesis/Src/Config/appColors.dart';
import 'package:sistema_genesis/Src/Routes/appRoutes.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    required this.currentPath,
    required this.child,
    super.key,
  });

  final String currentPath;
  final Widget child;

  static const _items = [
    (label: 'Visão geral', icon: Icons.dashboard_outlined, path: AppRoutes.dashboard),
    (label: 'Projetos', icon: Icons.work_outline, path: AppRoutes.projects),
    (label: 'Clientes', icon: Icons.people_outline, path: AppRoutes.clients),
    (label: 'Agenda', icon: Icons.calendar_month_outlined, path: AppRoutes.agenda),
    (label: 'Financeiro', icon: Icons.account_balance_wallet_outlined, path: AppRoutes.finance),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _items.indexWhere((item) => item.path == currentPath);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            onDestinationSelected: (index) => context.go(_items[index].path),
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.navy,
            selectedIconTheme: const IconThemeData(color: AppColors.lime),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(color: AppColors.lime),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: CircleAvatar(
                backgroundColor: AppColors.lime,
                child: Icon(Icons.layers_outlined, color: AppColors.navy),
              ),
            ),
            destinations: [
              for (final item in _items)
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
            'Acompanhe projetos, compromissos e movimentações da empresa.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.muted,
                ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _SummaryCard(label: 'Projetos em andamento', value: '0', icon: Icons.work_outline),
              _SummaryCard(label: 'Clientes ativos', value: '0', icon: Icons.people_outline),
              _SummaryCard(label: 'A receber', value: 'R\$ 0,00', icon: Icons.south_west),
              _SummaryCard(label: 'Despesas do mês', value: 'R\$ 0,00', icon: Icons.north_east),
            ],
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Comece por aqui', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Cadastre um cliente e crie seu primeiro projeto.'),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.projects),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
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
              Icon(icon, color: AppColors.navy),
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
