import 'package:flutter/material.dart';
import 'package:sistema_genesis/Src/Pages/Components/modulePage.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      title: 'Projetos',
      description: 'Propostas e projetos em negociação, execução, atraso ou concluídos.',
      icon: Icons.work_outline,
    );
  }
}
