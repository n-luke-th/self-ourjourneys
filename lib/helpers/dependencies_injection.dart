/// lib/helpers/dependencies_injection.dart
///
/// dependencies registration and injection
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/services/api/api_service.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/auth/local/local_auth_service.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';
import 'package:ourjourneys/services/configs/utils/permission_service.dart';
import 'package:ourjourneys/services/db/firestore_service.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/services/network/dio_handler.dart';
import 'package:ourjourneys/services/package/package_info_provider.dart';
import 'package:ourjourneys/services/package/package_info_service.dart';
import 'package:ourjourneys/services/pref/shared_pref_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  setupAuthServices();
  setupDio();
  setupApiServices();
  setupCloudFileServices();
  setupFirestoreServices();
  setupPackageInfoServices();
  await setupSharedPref();
  getIt.registerSingleton<PermissionsService>(PermissionsService());
  getIt.registerLazySingleton<LocalAuthService>(() => LocalAuthService());
}

void setupPackageInfoServices() {
  getIt.registerLazySingleton(() => PackageInfoService());
  getIt.registerLazySingleton(
      () => PackageInfoProvider(getIt<PackageInfoService>()));
}

Future<void> setupSharedPref() async {
  final sharedPrefsService = SharedPreferencesService();
  await sharedPrefsService.init();
  getIt.registerSingleton<SharedPreferencesService>(sharedPrefsService);
}

void setupAuthServices() {
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => AuthWrapper());
}

void setupLoggers() {
  getIt.registerSingleton<Logger>(Logger());
  getIt.registerSingleton<PrettyDioLogger>(PrettyDioLogger());
}

void setupApiServices() {
  getIt.registerLazySingleton(() => ApiService());
}

void setupDio() {
  getIt.registerLazySingleton<DioHandler>(() => DioHandler(Dio()));
}

void setupCloudFileServices() {
  getIt.registerLazySingleton(() => CloudFileService());
}

void setupFirestoreServices() {
  getIt.registerLazySingleton(() => FirestoreService());
  getIt.registerLazySingleton(() => FirestoreWrapper());
}
