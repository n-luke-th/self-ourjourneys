/// lib/services/package/package_info_provider.dart
///
/// a package info provider

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xiaokeai/services/package/package_info_service.dart';

class PackageInfoProvider extends ChangeNotifier {
  final PackageInfoService _service;
  PackageInfo? _packageInfo;

  PackageInfoProvider(this._service);

  PackageInfo? get packageInfo => _packageInfo;

  Future<void> loadPackageInfo() async {
    _packageInfo = await _service.getPackageInfo();
    notifyListeners();
  }
}
