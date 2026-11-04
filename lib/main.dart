import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_genesis/Src/Config/appTheme.dart';
import 'package:sistema_genesis/Src/Dependencies/dependencies.dart';
import 'package:sistema_genesis/Src/Services/authController.dart';
import 'package:sistema_genesis/Src/Services/genesisController.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await getIt<AuthController>().initialize();
  await getIt<GenesisController>().initialize();
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
