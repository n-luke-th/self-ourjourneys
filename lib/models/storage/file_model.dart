/// data models for object storage and api requests/responses
///
/// lib/models/storage/file_model.dart
///
///
///

/// data model for response from upload request
class FileResult {
  final String fileName;
  final String key;
  final String url;

  FileResult({
    required this.fileName,
    required this.key,
    required this.url,
  });

  factory FileResult.fromJson(Map<String, dynamic> json) {
    return FileResult(
      fileName: json['fileName'],
      key: json['key'],
      url: json['url'],
    );
  }
}

/// data model for response from delete request
class DeleteResult {
  final String key;

  DeleteResult({required this.key});

  factory DeleteResult.fromJson(Map<String, dynamic> json) {
    return DeleteResult(key: json['Key']);
  }
}

class RequestContext {
  final String? email;
  final String? uid;

  RequestContext({this.email, this.uid});

  factory RequestContext.fromJson(Map<String, dynamic> json) {
    final lambda = json['authorizer']?['lambda'] ?? {};
    return RequestContext(
      email: lambda['email'],
      uid: lambda['uid'],
    );
  }
}
