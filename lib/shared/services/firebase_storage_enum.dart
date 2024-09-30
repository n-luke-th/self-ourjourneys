/// lib/shared/services/firebase_storage_enum.dart
///
/// paths for object storage
enum FirebaseStoragePaths {
  /// memories = 'memories'
  ///
  /// this path meant to be the location for contents for 'memories' feature
  memories('memories'),

  /// profile = 'profile'
  ///
  /// this path meant to be the location for profile picture uploaded by user
  profile('profile'),

  /// albums = 'albums'
  ///
  /// this path meant to be the location for contents for 'memories' feature
  albums("albums"),

  /// userContent = 'userContent'
  ///
  /// this path meant to be uncategorized location to any content uploaded by user
  userContent('userContent');

  final String value;

  const FirebaseStoragePaths(this.value);
}
