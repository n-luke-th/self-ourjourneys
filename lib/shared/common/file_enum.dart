/// lib/shared/common/file_enum.dart
///
///

/// An enumeration of file picker modes.
enum FilePickerMode {
  /// meant to support image or video file type
  ///
  /// opens the platform photo/video library
  libraryPicker,

  /// meant to support any file type
  ///
  /// opens the platform file picker
  filePicker,
}

/// An enumeration of file size units.
/// this is used to display the file size in a human-readable format
/// e.g. 'MB', 'KB', 'B'
enum FileSizeUnit {
  /// Represents 'bytes' (B).
  bytes("B"),

  /// Represents 'kilobytes' (KB).
  kilobytes("KB"),

  /// Represents 'megabytes' (MB).
  megabytes("MB"),

  /// Represents 'gigabytes' (GB).
  gigabytes("GB"),

  /// Represents 'terabytes' (TB).
  terabytes("TB"),

  /// Represents 'petabytes' (PB).
  petabytes("PB");

  final String abbreviation;
  const FileSizeUnit(this.abbreviation);

  static FileSizeUnit fromAbbreviation(String abbreviation) {
    return FileSizeUnit.values.firstWhere(
      (unit) => unit.abbreviation == abbreviation,
      orElse: () => FileSizeUnit.bytes,
    );
  }

  static String getAbbreviation(FileSizeUnit unit) {
    return unit.abbreviation;
  }

  static String getUnitName(FileSizeUnit unit) {
    return unit.name;
  }
}
