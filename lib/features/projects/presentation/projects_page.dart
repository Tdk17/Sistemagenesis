import 'package:flutter/material.dart';

import '../../../shared/presentation/module_placeholder.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Projetos',
      description: 'Cadastre propostas e acompanhe cada projeto do primeiro contato à conclusão.',
      icon: Icons.work_outline,
    );
  }
}
