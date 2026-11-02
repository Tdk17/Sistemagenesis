import 'package:flutter/material.dart';
import 'package:sistema_genesis/Src/Pages/Components/modulePage.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      title: 'Clientes',
      description: 'Contatos organizados e vinculados aos respectivos projetos.',
      icon: Icons.people_outline,
    );
  }
}
