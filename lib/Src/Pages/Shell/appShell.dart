import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_genesis/Src/Config/appColors.dart';
import 'package:sistema_genesis/Src/Config/appConfig.dart';
import 'package:sistema_genesis/Src/Dependencies/dependencies.dart';
import 'package:sistema_genesis/Src/Routes/appRoutes.dart';
import 'package:sistema_genesis/Src/Services/authController.dart';
import 'package:sistema_genesis/Src/Services/genesisController.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final Widget child;

  static const items = <NavItem>[
    NavItem('Visão geral', Icons.grid_view_rounded, AppRoutes.dashboard),
    NavItem('Projetos', Icons.view_kanban_rounded, AppRoutes.projects),
    NavItem('Clientes', Icons.groups_2_outlined, AppRoutes.clients),
    NavItem('Agenda', Icons.calendar_month_outlined, AppRoutes.agenda),
    NavItem(
      'Financeiro',
      Icons.account_balance_wallet_outlined,
      AppRoutes.finance,
    ),
  ];

  int get selectedIndex {
    final index = items.indexWhere((item) => item.path == currentPath);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1024;
        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: desktop
              ? null
              : AppBar(
                  titleSpacing: 4,
                  title: const GenesisBrand(compact: true),
                  actions: const [
                    SyncButton(compact: true),
                    SizedBox(width: 6),
                  ],
                ),
          drawer: desktop ? null : MobileDrawer(currentPath: currentPath),
          body: Row(
            children: [
              if (desktop) DesktopSidebar(currentPath: currentPath),
              Expanded(
                child: Column(
                  children: [
                    if (desktop) DesktopHeader(currentPath: currentPath),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: selectedIndex,
                  height: 70,
                  onDestinationSelected: (index) =>
                      context.go(items[index].path),
                  destinations: [
                    for (final item in items)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.icon, color: AppColors.blue),
                        label: item.shortLabel,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({required this.currentPath, super.key});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(right: BorderSide(color: Color(0xFF232934))),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 26, 20, 30),
              child: GenesisBrand(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  for (final item in AppShell.items)
                    SidebarItem(item: item, selected: item.path == currentPath),
                ],
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 22),
              child: OwnerCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  const SidebarItem({required this.item, required this.selected, super.key});

  final NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? AppColors.blue.withOpacity(.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(item.path),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.blueBright.withOpacity(.45)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: selected
                      ? AppColors.goldSoft
                      : const Color(0xFF8994A4),
                ),
                const SizedBox(width: 13),
                Text(
                  item.label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFB2BAC6),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (selected)
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopHeader extends StatelessWidget {
  const DesktopHeader({required this.currentPath, super.key});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final item = AppShell.items.firstWhere(
      (item) => item.path == currentPath,
      orElse: () => AppShell.items.first,
    );
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const Text(
                'Genesis • Central de gestão',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const Spacer(),
          const EnvironmentBadge(),
          const SizedBox(width: 12),
          const SyncButton(),
        ],
      ),
    );
  }
}

class EnvironmentBadge extends StatelessWidget {
  const EnvironmentBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final configured = AppConfig.isBack4AppConfigured;
    final color = configured ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            configured ? 'Back4App conectado' : 'Modo local',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class SyncButton extends StatelessWidget {
  const SyncButton({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return IconButton.filledTonal(
          tooltip: controller.syncMessage,
          onPressed: controller.isSyncing
              ? null
              : () async {
                  await controller.syncAll();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(controller.syncMessage)),
                  );
                },
          icon: controller.isSyncing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Badge(
                  isLabelVisible: controller.pendingSyncCount > 0,
                  label: Text('${controller.pendingSyncCount}'),
                  child: Icon(
                    AppConfig.isBack4AppConfigured
                        ? Icons.sync_rounded
                        : Icons.cloud_off_outlined,
                  ),
                ),
        );
      },
    );
  }
}

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({required this.currentPath, super.key});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.black,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(24), child: GenesisBrand()),
            for (final item in AppShell.items)
              ListTile(
                selected: item.path == currentPath,
                selectedTileColor: AppColors.blue.withOpacity(.18),
                leading: Icon(
                  item.icon,
                  color: item.path == currentPath
                      ? AppColors.goldSoft
                      : Colors.white60,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    color: item.path == currentPath
                        ? Colors.white
                        : Colors.white70,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go(item.path);
                },
              ),
            const Spacer(),
            const Padding(padding: EdgeInsets.all(18), child: OwnerCard()),
          ],
        ),
      ),
    );
  }
}

class OwnerCard extends StatelessWidget {
  const OwnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.gold,
            child: Text(
              'PH',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedro Henrique',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Administrador',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () => getIt<AuthController>().logOut(),
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white60,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}

class GenesisBrand extends StatelessWidget {
  const GenesisBrand({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 36 : 42,
          height: compact ? 36 : 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blueBright, AppColors.blue],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withOpacity(.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: AppColors.goldSoft,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GENESIS',
              style: TextStyle(
                color: compact ? AppColors.black : Colors.white,
                fontSize: compact ? 15 : 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
            Text(
              'BUSINESS OS',
              style: TextStyle(
                color: compact ? AppColors.blue : AppColors.goldSoft,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.7,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NavItem {
  const NavItem(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;

  String get shortLabel => label == 'Visão geral' ? 'Início' : label;
}
