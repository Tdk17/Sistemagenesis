import 'package:flutter/material.dart';
import 'package:sistema_genesis/Src/Config/appColors.dart';
import 'package:sistema_genesis/Src/Dependencies/dependencies.dart';
import 'package:sistema_genesis/Src/Models/genesisModels.dart';
import 'package:sistema_genesis/Src/Pages/Components/modulePage.dart';
import 'package:sistema_genesis/Src/Services/genesisController.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();
        final projects = controller.projects.where((project) {
          if (query.isEmpty) return true;
          final client = controller.clientById(project.clientId);
          return project.name.toLowerCase().contains(query) ||
              project.domain.toLowerCase().contains(query) ||
              (client?.name.toLowerCase().contains(query) ?? false);
        }).toList();

        return PageFrame(
          title: 'Pipeline de projetos',
          description: 'Arraste cada projeto entre as etapas para atualizar o andamento.',
          actions: [
            FilledButton.icon(
              onPressed: () => showProjectDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo projeto'),
            ),
          ],
          child: Column(
            children: [
              SurfaceCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Buscar projeto, cliente ou domínio…',
                          prefixIcon: Icon(Icons.search_rounded),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    StatusPill(
                      label: '${projects.length} projetos',
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final stage in ProjectStage.values) ...[
                        _PipelineColumn(
                          stage: stage,
                          projects: projects
                              .where((project) => project.stage == stage)
                              .toList(),
                        ),
                        if (stage != ProjectStage.values.last)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PipelineColumn extends StatelessWidget {
  const _PipelineColumn({required this.stage, required this.projects});

  final ProjectStage stage;
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    final color = projectStageColor(stage);
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) =>
          controller.moveProject(details.data, stage),
      builder: (context, candidates, rejected) {
        final active = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 292,
          constraints: const BoxConstraints(minHeight: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(.08) : const Color(0xFFEBEEF3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? color : AppColors.border,
              width: active ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stage.label,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${projects.length}',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (projects.isEmpty)
                Container(
                  width: double.infinity,
                  height: 108,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withOpacity(.7)
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active
                          ? color.withOpacity(.35)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    active ? 'Solte o projeto aqui' : 'Nenhum projeto',
                    style: TextStyle(
                      color: active ? color : AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                for (final project in projects) ...[
                  _DraggableProjectCard(project: project),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _DraggableProjectCard extends StatelessWidget {
  const _DraggableProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final card = _ProjectCard(project: project);
    return LongPressDraggable<String>(
      data: project.id,
      delay: const Duration(milliseconds: 180),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 268,
          child: Opacity(opacity: .94, child: _ProjectCard(project: project)),
        ),
      ),
      childWhenDragging: Opacity(opacity: .32, child: card),
      child: card,
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    final client = controller.clientById(project.clientId);
    final overdue =
        project.dueDate != null &&
        project.dueDate!.isBefore(DateTime.now()) &&
        project.stage != ProjectStage.published;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: overdue ? AppColors.danger.withOpacity(.35) : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(
                width: 30,
                height: 30,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await showProjectDialog(context, project: project);
                    } else if (value == 'delete') {
                      final confirmed = await confirmDelete(
                        context,
                        title: 'Excluir projeto?',
                        message:
                            'O projeto ${project.name} será removido do pipeline.',
                      );
                      if (confirmed) controller.deleteProject(project);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            client?.name ?? 'Sem cliente vinculado',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 16,
                color: AppColors.gold,
              ),
              const SizedBox(width: 6),
              Text(
                currencyFormat.format(project.value),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (project.pendingSync)
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 16,
                  color: AppColors.muted,
                ),
            ],
          ),
          if (project.dueDate != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: overdue ? AppColors.danger : AppColors.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  '${overdue ? 'Atrasado • ' : ''}${dateFormat.format(project.dueDate!)}',
                  style: TextStyle(
                    color: overdue ? AppColors.danger : AppColors.muted,
                    fontSize: 11,
                    fontWeight: overdue ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (project.domain.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 15,
                  color: AppColors.blue,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    project.domain,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.blue, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> showProjectDialog(BuildContext context, {Project? project}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProjectDialog(project: project),
  );
}

class _ProjectDialog extends StatefulWidget {
  const _ProjectDialog({this.project});

  final Project? project;

  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _value;
  late final TextEditingController _domain;
  late final TextEditingController _siteUrl;
  late final TextEditingController _repositoryUrl;
  late final TextEditingController _notes;
  late ProjectStage _stage;
  String _clientId = '';
  DateTime? _dueDate;
  DateTime? _domainExpiration;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _name = TextEditingController(text: project?.name ?? '');
    _value = TextEditingController(
      text: project == null || project.value == 0
          ? ''
          : project.value.toStringAsFixed(2).replaceAll('.', ','),
    );
    _domain = TextEditingController(text: project?.domain ?? '');
    _siteUrl = TextEditingController(text: project?.siteUrl ?? '');
    _repositoryUrl = TextEditingController(text: project?.repositoryUrl ?? '');
    _notes = TextEditingController(text: project?.notes ?? '');
    _stage = project?.stage ?? ProjectStage.analysis;
    _clientId = project?.clientId ?? '';
    _dueDate = project?.dueDate;
    _domainExpiration = project?.domainExpiration;
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    _domain.dispose();
    _siteUrl.dispose();
    _repositoryUrl.dispose();
    _notes.dispose();
    super.dispose();
  }

  double _moneyValue() {
    final normalized = _value.text
        .trim()
        .replaceAll(RegExp(r'[^0-9,.]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  Future<void> _pickDate({required bool domain}) async {
    final current = domain ? _domainExpiration : _dueDate;
    final value = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (value == null) return;
    setState(() {
      if (domain) {
        _domainExpiration = value;
      } else {
        _dueDate = value;
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final controller = getIt<GenesisController>();
    final now = DateTime.now();
    final current = widget.project;
    controller.saveProject(
      Project(
        id: current?.id ?? controller.createId('project'),
        name: _name.text.trim(),
        clientId: _clientId,
        value: _moneyValue(),
        stage: _stage,
        dueDate: _dueDate,
        domain: _domain.text.trim(),
        domainExpiration: _domainExpiration,
        siteUrl: _siteUrl.text.trim(),
        repositoryUrl: _repositoryUrl.text.trim(),
        notes: _notes.text.trim(),
        createdAt: current?.createdAt ?? now,
        updatedAt: now,
        remoteId: current?.remoteId,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 860),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project == null
                                ? 'Novo projeto'
                                : 'Editar projeto',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Escopo, valores, prazos e ativos digitais.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _name,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Nome do projeto *',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Informe o nome do projeto.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final vertical = constraints.maxWidth < 570;
                          final clientField = DropdownButtonFormField<String>(
                            value:
                                controller.clients.any(
                                  (item) => item.id == _clientId,
                                )
                                ? _clientId
                                : '',
                            decoration: const InputDecoration(
                              labelText: 'Cliente',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('Sem cliente vinculado'),
                              ),
                              for (final client in controller.clients)
                                DropdownMenuItem(
                                  value: client.id,
                                  child: Text(
                                    client.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _clientId = value ?? ''),
                          );
                          final stageField =
                              DropdownButtonFormField<ProjectStage>(
                                value: _stage,
                                decoration: const InputDecoration(
                                  labelText: 'Etapa',
                                ),
                                items: [
                                  for (final stage in ProjectStage.values)
                                    DropdownMenuItem(
                                      value: stage,
                                      child: Text(stage.label),
                                    ),
                                ],
                                onChanged: (value) {
                                  if (value != null)
                                    setState(() => _stage = value);
                                },
                              );
                          if (vertical) {
                            return Column(
                              children: [
                                clientField,
                                const SizedBox(height: 14),
                                stageField,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: clientField),
                              const SizedBox(width: 14),
                              Expanded(child: stageField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final vertical = constraints.maxWidth < 570;
                          final valueField = TextFormField(
                            controller: _value,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Valor do projeto',
                              prefixText: 'R\$ ',
                            ),
                          );
                          final dateField = _DateField(
                            label: 'Prazo de entrega',
                            value: _dueDate,
                            onTap: () => _pickDate(domain: false),
                            onClear: () => setState(() => _dueDate = null),
                          );
                          if (vertical) {
                            return Column(
                              children: [
                                valueField,
                                const SizedBox(height: 14),
                                dateField,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: valueField),
                              const SizedBox(width: 14),
                              Expanded(child: dateField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Ativos digitais',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final vertical = constraints.maxWidth < 570;
                          final domainField = TextFormField(
                            controller: _domain,
                            decoration: const InputDecoration(
                              labelText: 'Domínio',
                              hintText: 'cliente.com.br',
                            ),
                          );
                          final expirationField = _DateField(
                            label: 'Vencimento do domínio',
                            value: _domainExpiration,
                            onTap: () => _pickDate(domain: true),
                            onClear: () =>
                                setState(() => _domainExpiration = null),
                          );
                          if (vertical) {
                            return Column(
                              children: [
                                domainField,
                                const SizedBox(height: 14),
                                expirationField,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: domainField),
                              const SizedBox(width: 14),
                              Expanded(child: expirationField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _siteUrl,
                        decoration: const InputDecoration(
                          labelText: 'Endereço do site',
                          hintText: 'https://…',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _repositoryUrl,
                        decoration: const InputDecoration(
                          labelText: 'Repositório',
                          hintText: 'https://github.com/…',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _notes,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Escopo e observações',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Salvar projeto'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: value == null
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
        ),
        child: Text(
          value == null ? 'Selecionar data' : dateFormat.format(value!),
          style: TextStyle(
            color: value == null ? AppColors.muted : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

Color projectStageColor(ProjectStage stage) => switch (stage) {
  ProjectStage.analysis => const Color(0xFF64748B),
  ProjectStage.awaitingApproval => AppColors.warning,
  ProjectStage.planned => const Color(0xFF7C3AED),
  ProjectStage.inProgress => AppColors.blue,
  ProjectStage.validation => const Color(0xFF0891B2),
  ProjectStage.published => AppColors.success,
};
