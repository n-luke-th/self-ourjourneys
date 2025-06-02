/// lib/models/storage/thumbnail_model.dart
///
/// thumbnail generation request and response models

// REQUEST MODELS

///
/// A class that represents the request to the thumbnail generation API.
class ThumbnailRequest {
  final String inputImage;
  final String inputImageName;

  /// Describes how the image is encoded in the HTTP body.
  ///
  ///  "base64"
  final String inputEncoding;

  /// What Flutter expects to receive

  /// "Uint8List", "base64", "bytes"
  final String inputImageDataType;
  final OutputConfigs outputConfigs;

  ThumbnailRequest({
    required this.inputImage,
    required this.inputImageName,
    required this.inputEncoding,
    required this.inputImageDataType,
    required this.outputConfigs,
  });

  Map<String, dynamic> toJson() => {
        "inputImage": inputImage,
        "inputImageName": inputImageName,
        "inputEncoding": inputEncoding,
        "inputImageDataType": inputImageDataType,
        "outputConfigs": outputConfigs.toJson(),
      };
}

/// contains the output configs for the thumbnail generation request
/// like the output image file extension, output image name, etc.
class OutputConfigs {
  final String outputImageDataType;
  final String outputImageFileExtension;
  final String outputImageName;
  final double imageQuality;
  final int maxFileSize;
  final String maxFileSizeUnit;
  final int? width;
  final int? height;
  final bool preserveAspectRatio;

  OutputConfigs({
    required this.outputImageDataType,
    required this.outputImageFileExtension,
    required this.outputImageName,
    required this.imageQuality,
    required this.maxFileSize,
    required this.maxFileSizeUnit,
    this.width,
    this.height,
    this.preserveAspectRatio = true,
  });

  Map<String, dynamic> toJson() => {
        "outputImageDataType": outputImageDataType,
        "outputImageFileExtension": outputImageFileExtension,
        "outputImageName": outputImageName,
        "imageQuality": imageQuality,
        "maxFileSize": maxFileSize,
        "maxFileSizeUnit": maxFileSizeUnit,
        if (width != null) "width": width,
        if (height != null) "height": height,
        "preserveAspectRatio": preserveAspectRatio,
      };
}

// END REQUEST MODELS

// RESPONSE MODELS

/// A class that represents the response from the thumbnail generation API.
class ThumbnailResponse {
  final bool isGenerated;
  final OutputData? outputData;
  final InputMetadata? inputMetadata;
  final String? errorMessage;

  ThumbnailResponse({
    required this.isGenerated,
    this.outputData,
    this.inputMetadata,
    this.errorMessage,
  });

  factory ThumbnailResponse.fromJson(Map<String, dynamic> json) {
    return ThumbnailResponse(
      isGenerated: json['isGenerated'],
      outputData: json['outputData'] != null
          ? OutputData.fromJson(json['outputData'])
          : null,
      inputMetadata: json['inputMetadata'] != null
          ? InputMetadata.fromJson(json['inputMetadata'])
          : null,
      errorMessage: json['errorMessage'],
    );
  }
}

/// tells us about the input image on the api response
class InputMetadata {
  final String inputImageName;
  final int detectedInputImageSize;
  final String detectedInputImageSizeUnit; // e.g., "B", "KB"
  final String detectedInputFileExtension; // e.g., "jpg"
  final String detectedInputMimeType; // e.g., "image/jpeg"

  InputMetadata({
    required this.inputImageName,
    required this.detectedInputImageSize,
    required this.detectedInputImageSizeUnit,
    required this.detectedInputFileExtension,
    required this.detectedInputMimeType,
  });

  factory InputMetadata.fromJson(Map<String, dynamic> json) {
    return InputMetadata(
      inputImageName: json['inputImageName'],
      detectedInputImageSize: json['detectedInputImageSize'],
      detectedInputImageSizeUnit: json['detectedInputImageSizeUnit'],
      detectedInputFileExtension: json['detectedInputFileExtension'],
      detectedInputMimeType: json['detectedInputMimeType'],
    );
  }
}

/// tells us everything we need to know about the output image on the api response
/// (e.g., the image data, the file extension, etc.)
/// null if the image was not generated
class OutputData {
  final String outputImage;

  /// What Flutter expects to receive
  /// "base64", "Uint8List"
  final String outputImageDataType;
  final String outputImageFileExtension;
  final String outputImageName;
  final double imageQuality;
  final int fileSize;
  final String fileSizeUnit;
  final int width;
  final int height;

  /// How the response data is encoded in the JSON response
  /// "base64"
  final String outputEncoding;

  OutputData({
    required this.outputImage,
    required this.outputImageDataType,
    required this.outputImageFileExtension,
    required this.outputImageName,
    required this.imageQuality,
    required this.fileSize,
    required this.fileSizeUnit,
    required this.width,
    required this.height,
    required this.outputEncoding,
  });

  factory OutputData.fromJson(Map<String, dynamic> json) {
    return OutputData(
      outputImage: json['outputImage'],
      outputImageDataType: json['outputImageDataType'],
      outputImageFileExtension: json['outputImageFileExtension'],
      outputImageName: json['outputImageName'],
      imageQuality: json['imageQuality'].toDouble(),
      fileSize: json['fileSize'],
      fileSizeUnit: json['fileSizeUnit'],
      width: json['width'],
      height: json['height'],
      outputEncoding: json['outputEncoding'],
    );
  }
}

// END RESPONSE MODELS
