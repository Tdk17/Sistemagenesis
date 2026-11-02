import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_genesis/Src/Config/appConfig.dart';
import 'package:sistema_genesis/Src/Connection/httpManager.dart';
import 'package:sistema_genesis/Src/Routes/appRouter.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  if (getIt.isRegistered<GoRouter>()) return;

  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: AppConfig.parseServerUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
      ),
    ),
  );

  getIt.registerLazySingleton<HttpManager>(
    () => HttpManager(getIt<Dio>()),
  );

  getIt.registerLazySingleton<GoRouter>(createAppRouter);
}
