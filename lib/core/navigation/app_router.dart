import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/agenda/presentation/agenda_page.dart';
import '../../features/clients/presentation/clients_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/finance/presentation/finance_page.dart';
import '../../features/projects/presentation/projects_page.dart';
import '../../shared/presentation/genesis_shell.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => GenesisShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/projects',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProjectsPage(),
            ),
          ),
          GoRoute(
            path: '/clients',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ClientsPage(),
            ),
          ),
          GoRoute(
            path: '/agenda',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AgendaPage(),
            ),
          ),
          GoRoute(
            path: '/finance',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FinancePage(),
            ),
          ),
        ],
      ),
    ],
  );
}
