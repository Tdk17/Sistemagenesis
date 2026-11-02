import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_router.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerSingleton<GoRouter>(createAppRouter());
}
