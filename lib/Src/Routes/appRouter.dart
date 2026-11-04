import 'package:go_router/go_router.dart';
import 'package:sistema_genesis/Src/Pages/Agenda/agenda.dart';
import 'package:sistema_genesis/Src/Pages/Clients/clients.dart';
import 'package:sistema_genesis/Src/Pages/Dashboard/dashboard.dart';
import 'package:sistema_genesis/Src/Pages/Finance/finance.dart';
import 'package:sistema_genesis/Src/Pages/Projects/projects.dart';
import 'package:sistema_genesis/Src/Pages/Auth/loginPage.dart';
import 'package:sistema_genesis/Src/Pages/Shell/appShell.dart';
import 'package:sistema_genesis/Src/Routes/appRoutes.dart';
import 'package:sistema_genesis/Src/Services/authController.dart';

GoRouter createAppRouter(AuthController authController) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authController,
    redirect: (context, state) {
      final atLogin = state.matchedLocation == AppRoutes.login;
      if (!authController.isAuthenticated && !atLogin) {
        return AppRoutes.login;
      }
      if (authController.isAuthenticated && atLogin) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (_, __) => authController.isAuthenticated
            ? AppRoutes.dashboard
            : AppRoutes.login,
      ),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.projects,
            builder: (_, __) => const ProjectsPage(),
          ),
          GoRoute(
            path: AppRoutes.clients,
            builder: (_, __) => const ClientsPage(),
          ),
          GoRoute(
            path: AppRoutes.agenda,
            builder: (_, __) => const AgendaPage(),
          ),
          GoRoute(
            path: AppRoutes.finance,
            builder: (_, __) => const FinancePage(),
          ),
        ],
      ),
    ],
  );
}
