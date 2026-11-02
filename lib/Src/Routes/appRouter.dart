import 'package:go_router/go_router.dart';
import 'package:sistema_genesis/Src/Pages/Agenda/agenda.dart';
import 'package:sistema_genesis/Src/Pages/Clients/clients.dart';
import 'package:sistema_genesis/Src/Pages/Dashboard/dashboard.dart';
import 'package:sistema_genesis/Src/Pages/Finance/finance.dart';
import 'package:sistema_genesis/Src/Pages/Projects/projects.dart';
import 'package:sistema_genesis/Src/Routes/appRoutes.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) => DashboardShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardPage()),
          GoRoute(path: AppRoutes.projects, builder: (_, __) => const ProjectsPage()),
          GoRoute(path: AppRoutes.clients, builder: (_, __) => const ClientsPage()),
          GoRoute(path: AppRoutes.agenda, builder: (_, __) => const AgendaPage()),
          GoRoute(path: AppRoutes.finance, builder: (_, __) => const FinancePage()),
        ],
      ),
    ],
  );
}
