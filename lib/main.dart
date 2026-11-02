import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_genesis/Src/Config/appTheme.dart';
import 'package:sistema_genesis/Src/Dependencies/dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const GenesisApp());
}

class GenesisApp extends StatelessWidget {
  const GenesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Genesis',
      theme: AppTheme.light,
      routerConfig: getIt<GoRouter>(),
    );
  }
}
