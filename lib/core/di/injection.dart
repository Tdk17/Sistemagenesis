import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../app/genesis_app.dart';
import '../navigation/app_router.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton<GoRouter>(createAppRouter());
  runApp(const GenesisApp());
}
