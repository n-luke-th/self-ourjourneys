/// lib/helpers/dependencies_injection.dart
///
/// dependencies registration and injection
import 'package:get_it/get_it.dart';
import 'package:xiaokeai/helpers/get_platform_service.dart';
import 'package:xiaokeai/services/auth/acc/auth_service.dart';
import 'package:xiaokeai/services/auth/acc/auth_wrapper.dart';
import 'package:xiaokeai/services/auth/local/local_auth_service.dart';
import 'package:xiaokeai/services/configs/utils/permission_service.dart';
import 'package:xiaokeai/services/object_storage/cloud_object_storage_service.dart';
import 'package:xiaokeai/services/object_storage/cloud_object_storage_wrapper.dart';
import 'package:xiaokeai/services/package/package_info_provider.dart';
import 'package:xiaokeai/services/package/package_info_service.dart';
import 'package:xiaokeai/services/pref/shared_pref_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // getIt.registerLazySingleton(() => AuthService());
  // getIt.registerLazySingleton(() => AuthWrapper());

  // getIt.registerLazySingleton(() => CloudObjectStorageService());
  // getIt.registerLazySingleton(() => CloudObjectStorageWrapper());
  setupAuthServices();
  setupCloudObjectStorageServices();
  // getIt.registerLazySingleton(() => FirestoreService());
  // getIt.registerLazySingleton(() => FirestoreWrapper());
  getIt.registerLazySingleton(() => PackageInfoService());
  getIt.registerLazySingleton(
      () => PackageInfoProvider(getIt<PackageInfoService>()));
  await setupSharedPref();
  getIt.registerSingleton<PermissionsService>(PermissionsService());
  getIt.registerSingleton<PlatformDetectionService>(PlatformDetectionService());
  getIt.registerLazySingleton<LocalAuthService>(() => LocalAuthService());
  // getIt.registerLazySingleton(() => SpeechService());
}

void setupCloudObjectStorageServices() {
  getIt.registerLazySingleton(() => CloudObjectStorageService());
  getIt.registerLazySingleton(() => CloudObjectStorageWrapper());
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
