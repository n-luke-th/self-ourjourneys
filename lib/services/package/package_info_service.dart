/// lib/services/package/package_info_service.dart
///
/// a package info service file
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoService {
  Future<PackageInfo> getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }
}
