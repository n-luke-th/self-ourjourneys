/// contains the image provider io stub to conditionally export the correct image provider io
export 'image_provider_io.dart'
    // if (dart.library.html) 'image_provider_web.dart';
    if (dart.library.js_interop) 'image_provider_web.dart';
