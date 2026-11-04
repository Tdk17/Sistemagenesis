import 'package:flutter/material.dart';
import 'package:sistema_genesis/Src/Config/appColors.dart';
import 'package:sistema_genesis/Src/Dependencies/dependencies.dart';
import 'package:sistema_genesis/Src/Models/genesisModels.dart';
import 'package:sistema_genesis/Src/Pages/Components/modulePage.dart';
import 'package:sistema_genesis/Src/Services/genesisController.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
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
        final clients = controller.clients.where((client) {
          if (query.isEmpty) return true;
          return client.name.toLowerCase().contains(query) ||
              client.company.toLowerCase().contains(query) ||
              client.email.toLowerCase().contains(query) ||
              client.phone.toLowerCase().contains(query);
        }).toList();

        return PageFrame(
          title: 'Clientes',
          description:
              'Centralize contatos e acompanhe os projetos de cada cliente.',
          actions: [
            FilledButton.icon(
              onPressed: () => showClientDialog(context),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Novo cliente'),
            ),
          ],
          child: controller.clients.isEmpty
              ? EmptyState(
                  icon: Icons.groups_2_outlined,
                  title: 'Sua base de clientes começa aqui',
                  description: 'Cadastre o primeiro cliente para vinculá-lo aos projetos, agenda e financeiro.',
                  actionLabel: 'Cadastrar cliente',
                  onAction: () => showClientDialog(context),
                )
              : Column(
                  children: [
                    SurfaceCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Buscar por nome, empresa, e-mail ou telefone…',
                                prefixIcon: Icon(Icons.search_rounded),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blue.withOpacity(.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${clients.length} ${clients.length == 1 ? 'cliente' : 'clientes'}',
                              style: const TextStyle(
                                color: AppColors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: clients.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum cliente encontrado.',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final columns = constraints.maxWidth >= 1150
                                    ? 3
                                    : constraints.maxWidth >= 720
                                    ? 2
                                    : 1;
                                const gap = 14.0;
                                final width =
                                    (constraints.maxWidth -
                                        gap * (columns - 1)) /
                                    columns;
                                return SingleChildScrollView(
                                  child: Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: [
                                      for (final client in clients)
                                        SizedBox(
                                          width: width,
                                          child: _ClientCard(
                                            client: client,
                                            projectCount: controller.projects
                                                .where(
                                                  (project) =>
                                                      project.clientId ==
                                                      client.id,
                                                )
                                                .length,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client, required this.projectCount});

  final Client client;
  final int projectCount;

  @override
  Widget build(BuildContext context) {
    final controller = getIt<GenesisController>();
    final initials = client.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.blue.withOpacity(.1),
                child: Text(
                  initials.isEmpty ? '?' : initials,
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      client.company.isEmpty ? 'Pessoa física' : client.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await showClientDialog(context, client: client);
                  } else if (value == 'delete') {
                    final confirmed = await confirmDelete(
                      context,
                      title: 'Excluir cliente?',
                      message:
                          'O cliente ${client.name} será removido. Os projetos vinculados serão mantidos.',
                    );
                    if (confirmed) controller.deleteClient(client);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ContactLine(
            icon: Icons.phone_outlined,
            text: client.phone.isEmpty
                ? 'Telefone não informado'
                : client.phone,
          ),
          const SizedBox(height: 9),
          _ContactLine(
            icon: Icons.mail_outline_rounded,
            text: client.email.isEmpty ? 'E-mail não informado' : client.email,
          ),
          const SizedBox(height: 9),
          _ContactLine(
            icon: Icons.location_on_outlined,
            text: client.city.isEmpty ? 'Cidade não informada' : client.city,
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.folder_copy_outlined,
                size: 17,
                color: AppColors.gold,
              ),
              const SizedBox(width: 7),
              Text(
                '$projectCount ${projectCount == 1 ? 'projeto' : 'projetos'}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (client.pendingSync)
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 17,
                  color: AppColors.muted,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.muted),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

Future<void> showClientDialog(BuildContext context, {Client? client}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ClientDialog(client: client),
  );
}

class _ClientDialog extends StatefulWidget {
  const _ClientDialog({this.client});

  final Client? client;

  @override
  State<_ClientDialog> createState() => _ClientDialogState();
}

class _ClientDialogState extends State<_ClientDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _company;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    _name = TextEditingController(text: client?.name ?? '');
    _company = TextEditingController(text: client?.company ?? '');
    _email = TextEditingController(text: client?.email ?? '');
    _phone = TextEditingController(text: client?.phone ?? '');
    _city = TextEditingController(text: client?.city ?? '');
    _notes = TextEditingController(text: client?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _email.dispose();
    _phone.dispose();
    _city.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final controller = getIt<GenesisController>();
    final now = DateTime.now();
    final current = widget.client;
    controller.saveClient(
      Client(
        id: current?.id ?? controller.createId('client'),
        name: _name.text.trim(),
        company: _company.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        city: _city.text.trim(),
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
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
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
                            widget.client == null
                                ? 'Novo cliente'
                                : 'Editar cliente',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Informações comerciais e de contato.',
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
                    children: [
                      TextFormField(
                        controller: _name,
                        autofocus: true,
                        decoration: const InputDecoration(labelText: 'Nome *'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Informe o nome do cliente.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _company,
                        decoration: const InputDecoration(labelText: 'Empresa'),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final vertical = constraints.maxWidth < 520;
                          final fields = [
                            Expanded(
                              child: TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Telefone',
                                ),
                              ),
                            ),
                          ];
                          if (vertical) {
                            return Column(
                              children: [
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'E-mail',
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _phone,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefone',
                                  ),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              fields[0],
                              const SizedBox(width: 14),
                              fields[1],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _city,
                        decoration: const InputDecoration(
                          labelText: 'Cidade / UF',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _notes,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
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
                      label: const Text('Salvar cliente'),
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
