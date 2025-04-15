class NetworkConsts {
  /// the root url for the api: https://api.ourjourneys.lukecreated.com
  static const String apiRootUrl = 'https://api.ourjourneys.lukecreated.com';

  /// the version of the api: 2
  static const int apiVersion = 2;

  /// the base url for the api: https://api.ourjourneys.lukecreated.com/v2
  static const String apiBaseUrl = '$apiRootUrl/v$apiVersion';

  /// the header for the api: Content-Type
  static const String headerContentType = 'Content-Type';

  /// the header for the api: Authorization
  static const String headerAuthorization = 'Authorization';

  /// the header for the api: application/json
  static const String headerContentTypeJson = 'application/json';

  /// the header for the api: Bearer
  static const String headerAuthorizationBearer = 'Bearer';

  /// the url for the cdn: https://cdn.ourjourneys.lukecreated.com
  static const String cdnUrl = 'https://cdn.ourjourneys.lukecreated.com';
}
