import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/errors/auth_exception/auth_exception.dart';
import 'package:ourjourneys/errors/object_storage_exception/cloud_object_storage_exception.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/services/network/dio_handler.dart';
import 'package:ourjourneys/shared/errors_code_and_msg/auth_errors.dart';
import 'package:ourjourneys/shared/errors_code_and_msg/cloud_object_storage_errors.dart';
import 'package:ourjourneys/shared/services/network_const.dart';
import 'package:shimmer/shimmer.dart';

class CloudImage extends StatefulWidget {
  final String objectKey;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Duration fadeDuration;
  final Widget? errorWidget;
  final double shimmerBaseOpacity;

  /// Allow caching of the image, also attempts to load from cache first
  final bool allowCache;

  const CloudImage({
    super.key,
    required this.objectKey,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.errorWidget = const Icon(Icons.error_outline),
    this.shimmerBaseOpacity = 0.5,
    this.allowCache = true,
  });

  @override
  State<CloudImage> createState() => _CloudImageState();
}

class _CloudImageState extends State<CloudImage> with TickerProviderStateMixin {
  late Future<Uint8List> _imageFuture;
  final cache = DefaultCacheManager();
  final AuthService _auth = getIt<AuthService>();
  final Logger _logger = getIt<Logger>();
  final DioHandler _dioHandler = getIt<DioHandler>();

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImageSecurely();
  }

  Future<Uint8List> _loadImageSecurely() async {
    final cacheKey = widget.objectKey.hashCode.toString();
    if (widget.allowCache) {
      // Check local cache first
      final cachedFile = await cache.getFileFromCache(cacheKey);
      if (cachedFile != null) {
        _logger.i("Loaded image from cache: ${widget.objectKey}");
        return cachedFile.file.readAsBytes();
      }
    }

    if (!_auth.isUserLoggedIn()) {
      throw AuthException(
        errorEnum: AuthErrors.AUTH_C12,
        errorDetailsFromDependency: 'User not authenticated',
        st: StackTrace.current,
      );
    }

    final objectUrl = "${NetworkConsts.cdnUrl}/${widget.objectKey}";
    _logger.d('objectKey: ${widget.objectKey} | object URL: $objectUrl');

    try {
      final Dio dio = await _dioHandler.getClient(
          withAuth: true,
          jsonContentTypeForAuth: false,
          baseUrl: NetworkConsts.cdnUrl);
      final response = await dio.get<List<int>>(
        objectUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data!);
      if (widget.allowCache) {
        await cache.putFile(cacheKey, bytes);
      }
      return bytes;
    } catch (e, stack) {
      _logger.e("Failed to load image from server",
          error: e, stackTrace: stack);
      throw CloudObjectStorageException(
        st: StackTrace.current,
        errorDetailsFromDependency: 'Failed to load image bytes from server',
        errorEnum: CloudObjectStorageErrors.CLOS_S01,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmer();
        } else if (snapshot.hasError || snapshot.data == null) {
          _logger.e('Error loading cloud image', error: snapshot.error);
          return widget.errorWidget ??
              Center(child: Icon(Icons.broken_image, color: Colors.grey[400]));
        } else {
          return AnimatedSwitcher(
            duration: widget.fadeDuration,
            child: Image.memory(
              snapshot.data!,
              key: ValueKey(widget.objectKey),
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            ),
          );
        }
      },
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(widget.shimmerBaseOpacity),
      highlightColor: Colors.white.withOpacity(widget.shimmerBaseOpacity),
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
      ),
    );
  }
}
