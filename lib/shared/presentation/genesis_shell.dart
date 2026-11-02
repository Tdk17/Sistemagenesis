import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
