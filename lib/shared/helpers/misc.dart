/// lib/shared/helpers/misc.dart

/// the enum for the source to fetch the media from
enum FetchSourceMethod {
  server("server"),
  local("local");

  final String stringValue;

  const FetchSourceMethod(this.stringValue);
}
