import 'package:flutter/material.dart';

import '../../../shared/presentation/module_placeholder.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Clientes',
      description: 'Organize contatos e vincule cada cliente aos seus projetos.',
      icon: Icons.people_outline,
    );
  }
}
