import 'package:flutter/material.dart';
import 'package:sistema_genesis/Src/Config/appColors.dart';
import 'package:sistema_genesis/Src/Dependencies/dependencies.dart';
import 'package:sistema_genesis/Src/Models/genesisModels.dart';
import 'package:sistema_genesis/Src/Pages/Components/modulePage.dart';
import 'package:sistema_genesis/Src/Services/genesisController.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  FinanceType? _filter;

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final entries = controller.finance
            .where((entry) => _filter == null || entry.type == _filter)
            .toList();
        return PageFrame(
          title: 'Financeiro',
          description: 'Controle receitas, despesas, vencimentos e rentabilidade dos projetos.',
          actions: [
            FilledButton.icon(
              onPressed: () => showFinanceDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo lançamento'),
            ),
          ],
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1080
                      ? 4
                      : constraints.maxWidth >= 620
                      ? 2
                      : 1;
                  const gap = 12.0;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      SizedBox(
                        width: width,
                        child: MetricCard(
                          label: 'Entradas realizadas',
                          value: currencyFormat.format(controller.totalIncome),
                          icon: Icons.south_west_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: MetricCard(
                          label: 'Despesas pagas',
                          value: currencyFormat.format(
                            controller.totalExpenses,
                          ),
                          icon: Icons.north_east_rounded,
                          color: AppColors.danger,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: MetricCard(
                          label: 'A receber',
                          value: currencyFormat.format(controller.receivable),
                          icon: Icons.hourglass_bottom_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: MetricCard(
                          label: 'Saldo realizado',
                          value: currencyFormat.format(
                            controller.totalIncome - controller.totalExpenses,
                          ),
                          icon: Icons.account_balance_outlined,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Receitas'),
                    selected: _filter == FinanceType.income,
                    onSelected: (_) =>
                        setState(() => _filter = FinanceType.income),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Despesas'),
                    selected: _filter == FinanceType.expense,
                    onSelected: (_) =>
                        setState(() => _filter = FinanceType.expense),
                  ),
                  const Spacer(),
                  Text(
                    '${entries.length} lançamentos',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: controller.finance.isEmpty
                    ? EmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Seu financeiro ainda está vazio',
                        description: 'Registre valores de projetos, hospedagem, domínios, banco de dados e outras despesas.',
                        actionLabel: 'Criar lançamento',
                        onAction: () => showFinanceDialog(context),
                      )
                    : entries.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum lançamento neste filtro.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final entry in entries) ...[
                              _FinanceCard(entry: entry),
                              const SizedBox(height: 9),
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

class _FinanceCard extends StatelessWidget {
  const _FinanceCard({required this.entry});

  final FinanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    final project = controller.projectById(entry.projectId);
    final isIncome = entry.type == FinanceType.income;
    final color = isIncome ? AppColors.success : AppColors.danger;
    final overdue =
        entry.status == PaymentStatus.pending &&
        entry.dueDate.isBefore(DateTime.now());
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: overdue
          ? AppColors.danger.withOpacity(.3)
          : AppColors.border,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  [
                    entry.category,
                    if (project != null) project.name,
                  ].join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (MediaQuery.sizeOf(context).width >= 660) ...[
            SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vencimento',
                    style: TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                  Text(
                    dateFormat.format(entry.dueDate),
                    style: TextStyle(
                      color: overdue ? AppColors.danger : AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            StatusPill(
              label: overdue ? 'Vencido' : entry.status.label,
              color: overdue
                  ? AppColors.danger
                  : entry.status == PaymentStatus.paid
                  ? AppColors.success
                  : AppColors.warning,
            ),
            const SizedBox(width: 18),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} ${currencyFormat.format(entry.amount)}',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (MediaQuery.sizeOf(context).width < 660)
                Text(
                  entry.status.label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await showFinanceDialog(context, entry: entry);
              } else if (value == 'toggle') {
                controller.saveFinanceEntry(
                  entry.copyWith(
                    status: entry.status == PaymentStatus.paid
                        ? PaymentStatus.pending
                        : PaymentStatus.paid,
                  ),
                );
              } else if (value == 'delete') {
                final confirmed = await confirmDelete(
                  context,
                  title: 'Excluir lançamento?',
                  message: 'O lançamento ${entry.description} será removido.',
                );
                if (confirmed) controller.deleteFinanceEntry(entry);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(
                value: 'toggle',
                child: Text(
                  entry.status == PaymentStatus.paid
                      ? 'Marcar como pendente'
                      : 'Marcar como pago',
                ),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showFinanceDialog(BuildContext context, {FinanceEntry? entry}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _FinanceDialog(entry: entry),
  );
}

class _FinanceDialog extends StatefulWidget {
  const _FinanceDialog({this.entry});

  final FinanceEntry? entry;

  @override
  State<_FinanceDialog> createState() => _FinanceDialogState();
}

class _FinanceDialogState extends State<_FinanceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late final TextEditingController _category;
  late final TextEditingController _notes;
  late FinanceType _type;
  late PaymentStatus _status;
  late DateTime _dueDate;
  String _projectId = '';

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _description = TextEditingController(text: entry?.description ?? '');
    _amount = TextEditingController(
      text: entry == null || entry.amount == 0
          ? ''
          : entry.amount.toStringAsFixed(2).replaceAll('.', ','),
    );
    _category = TextEditingController(text: entry?.category ?? '');
    _notes = TextEditingController(text: entry?.notes ?? '');
    _type = entry?.type ?? FinanceType.income;
    _status = entry?.status ?? PaymentStatus.pending;
    _dueDate = entry?.dueDate ?? DateTime.now();
    _projectId = entry?.projectId ?? '';
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _category.dispose();
    _notes.dispose();
    super.dispose();
  }

  double _moneyValue() {
    final normalized = _amount.text
        .trim()
        .replaceAll(RegExp(r'[^0-9,.]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (value != null) setState(() => _dueDate = value);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final controller = getIt<GenesisController>();
    final now = DateTime.now();
    final current = widget.entry;
    controller.saveFinanceEntry(
      FinanceEntry(
        id: current?.id ?? controller.createId('finance'),
        description: _description.text.trim(),
        type: _type,
        status: _status,
        amount: _moneyValue(),
        category: _category.text.trim(),
        dueDate: _dueDate,
        projectId: _projectId,
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
    return AlertDialog(
      title: Text(
        widget.entry == null ? 'Novo lançamento' : 'Editar lançamento',
      ),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<FinanceType>(
                  segments: const [
                    ButtonSegment(
                      value: FinanceType.income,
                      label: Text('Receita'),
                      icon: Icon(Icons.south_west_rounded),
                    ),
                    ButtonSegment(
                      value: FinanceType.expense,
                      label: Text('Despesa'),
                      icon: Icon(Icons.north_east_rounded),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (value) =>
                      setState(() => _type = value.first),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _description,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Descrição *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe a descrição.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor *',
                    prefixText: 'R\$ ',
                  ),
                  validator: (_) =>
                      _moneyValue() <= 0 ? 'Informe um valor válido.' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria *',
                    hintText: 'Projeto, hospedagem, domínio, banco de dados…',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe a categoria.'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value:
                      controller.projects.any(
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
                    for (final project in controller.projects)
                      DropdownMenuItem(
                        value: project.id,
                        child: Text(project.name),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _projectId = value ?? ''),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Vencimento',
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    child: Text(dateFormat.format(_dueDate)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<PaymentStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Situação'),
                  items: [
                    for (final status in PaymentStatus.values)
                      DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
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
