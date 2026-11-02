import 'package:flutter/material.dart';

import '../../../shared/presentation/module_placeholder.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Agenda',
      description: 'Registre apresentações, reuniões, tarefas e prazos.',
      icon: Icons.calendar_month_outlined,
    );
  }
}
