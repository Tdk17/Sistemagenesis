import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sistema_genesis/Src/Config/appColors.dart';
import 'package:sistema_genesis/Src/Dependencies/dependencies.dart';
import 'package:sistema_genesis/Src/Models/genesisModels.dart';
import 'package:sistema_genesis/Src/Pages/Components/modulePage.dart';
import 'package:sistema_genesis/Src/Routes/appRoutes.dart';
import 'package:sistema_genesis/Src/Services/genesisController.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final activeProjects = controller.projects
            .where((project) => project.stage != ProjectStage.published)
            .length;
        final delayed = controller.projects.where((project) {
          final deadline = project.dueDate;
          return deadline != null &&
              deadline.isBefore(DateTime.now()) &&
              project.stage != ProjectStage.published;
        }).length;

        return PageFrame(
          title: 'Visão geral',
          description:
              'Acompanhe a operação e tome decisões sem perder prazos.',
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.clients),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Novo cliente'),
            ),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.projects),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo projeto'),
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1180
                        ? 4
                        : constraints.maxWidth >= 650
                        ? 2
                        : 1;
                    const gap = 14.0;
                    final width =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: width,
                          child: MetricCard(
                            label: 'Projetos ativos',
                            value: '$activeProjects',
                            icon: Icons.rocket_launch_outlined,
                            color: AppColors.blue,
                            caption: '$delayed com prazo vencido',
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: MetricCard(
                            label: 'Clientes',
                            value: '${controller.clients.length}',
                            icon: Icons.groups_2_outlined,
                            color: const Color(0xFF7C3AED),
                            caption: 'base comercial',
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: MetricCard(
                            label: 'A receber',
                            value: currencyFormat.format(controller.receivable),
                            icon: Icons.south_west_rounded,
                            color: AppColors.success,
                            caption: 'receitas pendentes',
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: MetricCard(
                            label: 'Saldo realizado',
                            value: currencyFormat.format(
                              controller.totalIncome - controller.totalExpenses,
                            ),
                            icon: Icons.insights_rounded,
                            color: AppColors.gold,
                            caption: 'entradas menos saídas',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop = constraints.maxWidth >= 940;
                    final pipeline = _PipelineOverview(controller: controller);
                    final agenda = _UpcomingAgenda(controller: controller);
                    if (!desktop) {
                      return Column(
                        children: [
                          pipeline,
                          const SizedBox(height: 18),
                          agenda,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: pipeline),
                        const SizedBox(width: 18),
                        Expanded(flex: 4, child: agenda),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop = constraints.maxWidth >= 940;
                    final deadlines = _DeadlinePanel(controller: controller);
                    final finance = _RecentFinance(controller: controller);
                    if (!desktop) {
                      return Column(
                        children: [
                          deadlines,
                          const SizedBox(height: 18),
                          finance,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: deadlines),
                        const SizedBox(width: 18),
                        Expanded(child: finance),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PipelineOverview extends StatelessWidget {
  const _PipelineOverview({required this.controller});

  final GenesisController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.projects.isEmpty ? 1 : controller.projects.length;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Pipeline de projetos',
            subtitle: 'Distribuição por etapa',
            actionLabel: 'Abrir pipeline',
            onAction: () => context.go(AppRoutes.projects),
          ),
          const SizedBox(height: 22),
          for (final stage in ProjectStage.values) ...[
            Builder(
              builder: (context) {
                final count = controller.projects
                    .where((project) => project.stage == stage)
                    .length;
                final color = _stageColor(stage);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stage.label,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '$count',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: count / total,
                          minHeight: 7,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _UpcomingAgenda extends StatelessWidget {
  const _UpcomingAgenda({required this.controller});

  final GenesisController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.agenda
        .where((item) => !item.done && item.dateTime.isAfter(DateTime.now()))
        .take(5)
        .toList();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Próximos compromissos',
            subtitle: 'Agenda prioritária',
            actionLabel: 'Ver agenda',
            onAction: () => context.go(AppRoutes.agenda),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const _CompactEmpty(
              icon: Icons.event_available_outlined,
              text: 'Nenhum compromisso futuro.',
            )
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('dd').format(item.dateTime),
                          style: const TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${item.kind.label} • ${DateFormat('HH:mm').format(item.dateTime)}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _DeadlinePanel extends StatelessWidget {
  const _DeadlinePanel({required this.controller});

  final GenesisController controller;

  @override
  Widget build(BuildContext context) {
    final deadlines =
        controller.projects
            .where((project) => project.domainExpiration != null)
            .toList()
          ..sort((a, b) => a.domainExpiration!.compareTo(b.domainExpiration!));
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            title: 'Domínios e prazos',
            subtitle: 'Vencimentos mais próximos',
          ),
          const SizedBox(height: 18),
          if (deadlines.isEmpty)
            const _CompactEmpty(
              icon: Icons.language_rounded,
              text:
                  'Cadastre domínios nos projetos para acompanhar vencimentos.',
            )
          else
            for (final project in deadlines.take(4))
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFF6DA),
                  child: Icon(Icons.language_rounded, color: AppColors.gold),
                ),
                title: Text(
                  project.domain.isEmpty ? project.name : project.domain,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(project.name),
                trailing: Text(
                  dateFormat.format(project.domainExpiration!),
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _RecentFinance extends StatelessWidget {
  const _RecentFinance({required this.controller});

  final GenesisController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.finance.take(4).toList();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Movimentações recentes',
            subtitle: 'Fluxo financeiro',
            actionLabel: 'Ver financeiro',
            onAction: () => context.go(AppRoutes.finance),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const _CompactEmpty(
              icon: Icons.receipt_long_outlined,
              text: 'Nenhuma movimentação financeira registrada.',
            )
          else
            for (final item in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: CircleAvatar(
                  backgroundColor:
                      (item.type == FinanceType.income
                              ? AppColors.success
                              : AppColors.danger)
                          .withOpacity(.1),
                  child: Icon(
                    item.type == FinanceType.income
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    color: item.type == FinanceType.income
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
                title: Text(
                  item.description,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(item.category),
                trailing: Text(
                  currencyFormat.format(item.amount),
                  style: TextStyle(
                    color: item.type == FinanceType.income
                        ? AppColors.success
                        : AppColors.danger,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _CompactEmpty extends StatelessWidget {
  const _CompactEmpty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.muted),
          const SizedBox(height: 9),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

Color _stageColor(ProjectStage stage) => switch (stage) {
  ProjectStage.analysis => const Color(0xFF64748B),
  ProjectStage.awaitingApproval => AppColors.warning,
  ProjectStage.planned => const Color(0xFF7C3AED),
  ProjectStage.inProgress => AppColors.blue,
  ProjectStage.validation => const Color(0xFF0891B2),
  ProjectStage.published => AppColors.success,
};
