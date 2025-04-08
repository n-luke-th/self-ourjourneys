import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ourjourneys/errors/auth_exception/auth_exception.dart';
import 'package:ourjourneys/errors/object_storage_exception/cloud_object_storage_exception.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/shared/common/general.dart';
import 'package:ourjourneys/shared/errors_code_and_msg/auth_errors.dart';
import 'package:ourjourneys/shared/errors_code_and_msg/cloud_object_storage_errors.dart';
import 'package:shimmer/shimmer.dart';

class CloudImage extends StatefulWidget {
  final String objectKey; // ← CHANGED: Now it accepts object key, not full URL
  final BoxFit fit;
  final double? width;
  final double? height;
  final Duration fadeDuration;
  final Widget? errorWidget;
  final double shimmerBaseOpacity;

  const CloudImage({
    super.key,
    required this.objectKey,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.errorWidget,
    this.shimmerBaseOpacity = 0.5,
  });

  @override
  State<CloudImage> createState() => _CloudImageState();
}

class _CloudImageState extends State<CloudImage> with TickerProviderStateMixin {
  late Future<Uint8List> _imageFuture;
  final cache = DefaultCacheManager();
  final AuthService _auth = getIt<AuthService>();
  final Logger _logger = getIt<Logger>();

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImageSecurely();
  }

  Future<String> _getSignedUrl(String objectKey) async {
    final user = _auth.authInstance!.currentUser;
    final idToken = await user!.getIdToken();

    final response = await http.post(
      Uri.parse('${General.apiUrl}/v1/r/obtain-signed-url'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'object_key': objectKey}),
    );
    _logger.d(response.toString());

    if (response.statusCode != 200) {
      throw CloudObjectStorageException(
        st: StackTrace.current,
        errorDetailsFromDependency: 'Failed to get signed CloudFront URL',
        errorEnum: CloudObjectStorageErrors.CLOS_S01,
      );
    }

    final data = jsonDecode(response.body);
    return data['signed_url'];
  }

  Future<Uint8List> _loadImageSecurely() async {
    final cacheKey = widget.objectKey.hashCode.toString();

    // Check local cache
    final cachedFile = await cache.getFileFromCache(cacheKey);
    if (cachedFile != null) {
      return cachedFile.file.readAsBytes();
    }

    // Ensure user is authenticated
    if (!_auth.isUserLoggedIn()) {
      throw AuthException(
        errorEnum: AuthErrors.AUTH_C12,
        errorDetailsFromDependency: 'User not authenticated',
        st: StackTrace.current,
      );
    }

    // Get signed CloudFront URL
    final signedUrl = await _getSignedUrl(widget.objectKey);
    _logger.d('objectKey: ${widget.objectKey} | Signed URL: $signedUrl');

    // Download image
    final response = await http.get(Uri.parse(signedUrl));
    if (response.statusCode != 200) {
      _logger.e("Failed to load image from CloudFront: ${response.statusCode}");
      throw CloudObjectStorageException(
        st: StackTrace.current,
        errorDetailsFromDependency: 'Failed to load image bytes',
        errorEnum: CloudObjectStorageErrors.CLOS_S01,
      );
    }

    // Cache and return image
    await cache.putFile(cacheKey, response.bodyBytes);
    return response.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmer();
        } else if (snapshot.hasError || snapshot.data == null) {
          _logger.e(snapshot.error.toString(), error: snapshot.error);
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
