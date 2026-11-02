import 'package:flutter/material.dart';
import 'package:sistema_genesis/Src/Pages/Components/modulePage.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      title: 'Financeiro',
      description: 'Receitas, despesas, vencimentos e valores a receber.',
      icon: Icons.account_balance_wallet_outlined,
    );
  }
}
