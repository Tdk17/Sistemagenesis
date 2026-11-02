import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
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
              Icon(icon, color: Theme.of(context).colorScheme.primary),
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
