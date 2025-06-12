/// lib/models/interface/base_image_configs.dart

import 'package:ourjourneys/models/interface/image_display_configs_model.dart';

/// a base mixin class for image viewer
///
/// contains the configs for the image to be displayed
/// as well as the source to fetch the image from

@Deprecated(
    'This class is deprecated and will be removed in the near future release. Please use the ImageDisplayConfigsModel class instead.')
mixin BaseImageConfigs {
  /// the configs for the image to be displayed
  ImageDisplayConfigsModel get imageRendererConfigs;
}
