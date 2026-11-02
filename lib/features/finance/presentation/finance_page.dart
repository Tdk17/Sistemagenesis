import 'package:flutter/material.dart';

import '../../../shared/presentation/module_placeholder.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: 'Financeiro',
      description: 'Acompanhe receitas, despesas, vencimentos e valores a receber.',
      icon: Icons.account_balance_wallet_outlined,
    );
  }
}
