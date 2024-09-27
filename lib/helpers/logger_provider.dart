/// lib/helpers/logger_provider.dart
///
/// a logger provider across the app
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLogger() {
  locator.registerSingleton<Logger>(Logger());
}
