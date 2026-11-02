import 'package:flutter/material.dart';
import 'package:sistema_genesis/Src/Pages/Components/modulePage.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      title: 'Agenda',
      description: 'Apresentações, reuniões, tarefas e prazos.',
      icon: Icons.calendar_month_outlined,
    );
  }
}
