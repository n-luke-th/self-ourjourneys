///lib/services/core/image_provider_cache.dart
import 'package:extended_image/extended_image.dart'
    show ExtendedNetworkImageProvider, ExtendedMemoryImageProvider;
import 'package:flutter/material.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/helpers/get_platform_service.dart'
    show PlatformDetectionService;
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/image_provider_io/image_provider_stub.dart'
    as image_provider_stub;
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/services/network_const.dart'
    show NetworkConsts;

/// the dedicated image renderer provider
/// which will return the cached version of the provider if exists or return the new provider
/// and cached it.
///
/// help improve performance and rebuilds
class ImageProviderCache extends ChangeNotifier {
  final Map<String, ImageProvider<Object>> _cache = {};

  /// Returns an [ImageProvider] for the given source.
  /// If it was already built, the same instance is returned.
  Future<ImageProvider<Object>> getProvider(
    FetchSourceData source,
    ImageDisplayConfigsModel cfg,
  ) async {
    final key = source.uniqueIdentityKey;
    if (_cache.containsKey(key)) return _cache[key]!;

    // --- build the provider only once ---
    ImageProvider<Object> provider;
    switch (source.fetchSourceMethod) {
      case FetchSourceMethod.server:
        final auth = getIt<AuthWrapper>();
        auth.refreshIdToken();
        provider = ExtendedNetworkImageProvider(
          '${NetworkConsts.cdnUrl}/${source.cloudFileObjectKey}',
          headers: {
            NetworkConsts.headerAuthorization:
                '${NetworkConsts.headerAuthorizationBearer} ${auth.idToken}',
          },
          scale: 1.0,
          cacheKey: source.cloudFileObjectKey.hashCode.toString(),
          cache: cfg.allowCache,
          cacheMaxAge: const Duration(days: 15),
          timeRetry: const Duration(milliseconds: 500),
        );
        break;

      case FetchSourceMethod.local:
        // -- Web: need bytes first --
        if (PlatformDetectionService.isWeb) {
          final bytes =
              source.localFileBytes ?? await source.localFile!.readAsBytes();
          provider = ExtendedMemoryImageProvider(bytes);
        } else {
          provider = image_provider_stub.localFileImageProvider(
            source.localFile!,
          );
        }
        break;
    }

    _cache[key] = provider;
    return provider;
  }
}
