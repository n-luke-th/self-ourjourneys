class ApiConsts {
  /// the root url for the api: https://api.ourjourneys.lukecreated.com
  static const String apiRootUrl = 'https://api.ourjourneys.lukecreated.com';

  /// the version of the api: 1
  static const int apiVersion = 1;

  /// the base url for the api: https://api.ourjourneys.lukecreated.com/v1
  static const String apiBaseUrl = '$apiRootUrl/v$apiVersion';

  /// the header for the api: Content-Type
  static const String headerContentType = 'Content-Type';

  /// the header for the api: Authorization
  static const String headerAuthorization = 'Authorization';

  /// the header for the api: application/json
  static const String headerContentTypeJson = 'application/json';

  /// the header for the api: Bearer
  static const String headerAuthorizationBearer = 'Bearer';
}
