import 'package:flutter/material.dart';
import 'package:sistema_genesis/Src/Config/appColors.dart';
import 'package:sistema_genesis/Src/Dependencies/dependencies.dart';
import 'package:sistema_genesis/Src/Models/genesisModels.dart';
import 'package:sistema_genesis/Src/Pages/Components/modulePage.dart';
import 'package:sistema_genesis/Src/Services/genesisController.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.agenda
            .where((item) => _showCompleted ? item.done : !item.done)
            .toList();
        return PageFrame(
          title: 'Agenda',
          description:
              'Organize reuniões, apresentações, tarefas e prazos da operação.',
          actions: [
            FilledButton.icon(
              onPressed: () => showAgendaDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo compromisso'),
            ),
          ],
          child: Column(
            children: [
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Pendentes'),
                    selected: !_showCompleted,
                    onSelected: (_) => setState(() => _showCompleted = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Concluídos'),
                    selected: _showCompleted,
                    onSelected: (_) => setState(() => _showCompleted = true),
                  ),
                  const Spacer(),
                  Text(
                    '${items.length} ${items.length == 1 ? 'item' : 'itens'}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: controller.agenda.isEmpty
                    ? EmptyState(
                        icon: Icons.calendar_month_outlined,
                        title: 'Nenhum compromisso agendado',
                        description: 'Registre apresentações, reuniões com clientes e prazos importantes.',
                        actionLabel: 'Agendar compromisso',
                        onAction: () => showAgendaDialog(context),
                      )
                    : items.isEmpty
                    ? Center(
                        child: Text(
                          _showCompleted
                              ? 'Nenhum compromisso concluído.'
                              : 'Todos os compromissos foram concluídos.',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final item in items) ...[
                              _AgendaCard(item: item),
                              const SizedBox(height: 10),
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

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.item});

  final AgendaEntry item;

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    final client = controller.clientById(item.clientId);
    final project = controller.projectById(item.projectId);
    final overdue = !item.done && item.dateTime.isBefore(DateTime.now());
    final color = agendaKindColor(item.kind);
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      borderColor: overdue
          ? AppColors.danger.withOpacity(.3)
          : AppColors.border,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.done,
            onChanged: (_) => controller.toggleAgendaEntry(item),
          ),
          const SizedBox(width: 4),
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: color.withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${item.dateTime.day}'.padLeft(2, '0'),
                  style: TextStyle(
                    color: color,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  _month(item.dateTime.month),
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: item.done ? AppColors.muted : AppColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        decoration: item.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    StatusPill(label: item.kind.label, color: color),
                    if (overdue)
                      const StatusPill(
                        label: 'Atrasado',
                        color: AppColors.danger,
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 14,
                  runSpacing: 5,
                  children: [
                    _AgendaMeta(
                      icon: Icons.schedule_rounded,
                      text: dateTimeFormat.format(item.dateTime),
                    ),
                    if (client != null)
                      _AgendaMeta(
                        icon: Icons.person_outline_rounded,
                        text: client.name,
                      ),
                    if (project != null)
                      _AgendaMeta(
                        icon: Icons.folder_outlined,
                        text: project.name,
                      ),
                  ],
                ),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.notes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await showAgendaDialog(context, entry: item);
              } else if (value == 'delete') {
                final confirmed = await confirmDelete(
                  context,
                  title: 'Excluir compromisso?',
                  message:
                      'O compromisso ${item.title} será removido da agenda.',
                );
                if (confirmed) controller.deleteAgendaEntry(item);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgendaMeta extends StatelessWidget {
  const _AgendaMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.muted),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

Future<void> showAgendaDialog(BuildContext context, {AgendaEntry? entry}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AgendaDialog(entry: entry),
  );
}

class _AgendaDialog extends StatefulWidget {
  const _AgendaDialog({this.entry});

  final AgendaEntry? entry;

  @override
  State<_AgendaDialog> createState() => _AgendaDialogState();
}

class _AgendaDialogState extends State<_AgendaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late AgendaKind _kind;
  late DateTime _dateTime;
  String _clientId = '';
  String _projectId = '';

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _title = TextEditingController(text: entry?.title ?? '');
    _notes = TextEditingController(text: entry?.notes ?? '');
    _kind = entry?.kind ?? AgendaKind.meeting;
    _dateTime = entry?.dateTime ?? DateTime.now().add(const Duration(hours: 1));
    _clientId = entry?.clientId ?? '';
    _projectId = entry?.projectId ?? '';
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _dateTime.hour,
        time?.minute ?? _dateTime.minute,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final controller = getIt<GenesisController>();
    final now = DateTime.now();
    final current = widget.entry;
    controller.saveAgendaEntry(
      AgendaEntry(
        id: current?.id ?? controller.createId('agenda'),
        title: _title.text.trim(),
        kind: _kind,
        dateTime: _dateTime,
        clientId: _clientId,
        projectId: _projectId,
        notes: _notes.text.trim(),
        done: current?.done ?? false,
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
    final availableProjects = _clientId.isEmpty
        ? controller.projects
        : controller.projects
              .where((project) => project.clientId == _clientId)
              .toList();
    if (!availableProjects.any((project) => project.id == _projectId)) {
      _projectId = '';
    }

    return AlertDialog(
      title: Text(
        widget.entry == null ? 'Novo compromisso' : 'Editar compromisso',
      ),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Título *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe o título.'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<AgendaKind>(
                  value: _kind,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    for (final kind in AgendaKind.values)
                      DropdownMenuItem(value: kind, child: Text(kind.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _kind = value);
                  },
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data e horário',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    child: Text(dateTimeFormat.format(_dateTime)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value:
                      controller.clients.any((client) => client.id == _clientId)
                      ? _clientId
                      : '',
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Sem cliente'),
                    ),
                    for (final client in controller.clients)
                      DropdownMenuItem(
                        value: client.id,
                        child: Text(client.name),
                      ),
                  ],
                  onChanged: (value) => setState(() {
                    _clientId = value ?? '';
                    _projectId = '';
                  }),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value:
                      availableProjects.any(
                        (project) => project.id == _projectId,
                      )
                      ? _projectId
                      : '',
                  decoration: const InputDecoration(labelText: 'Projeto'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Sem projeto'),
                    ),
                    for (final project in availableProjects)
                      DropdownMenuItem(
                        value: project.id,
                        child: Text(project.name),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _projectId = value ?? ''),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Observações'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}

Color agendaKindColor(AgendaKind kind) => switch (kind) {
  AgendaKind.meeting => AppColors.blue,
  AgendaKind.presentation => const Color(0xFF7C3AED),
  AgendaKind.deadline => AppColors.danger,
  AgendaKind.task => AppColors.gold,
};

String _month(int month) => const [
  'JAN',
  'FEV',
  'MAR',
  'ABR',
  'MAI',
  'JUN',
  'JUL',
  'AGO',
  'SET',
  'OUT',
  'NOV',
  'DEZ',
][month - 1];
