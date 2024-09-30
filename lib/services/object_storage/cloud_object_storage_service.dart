/// lib/services/object_storage/cloud_object_storage_service.dart
/// a cloud object storage service
///
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:universal_io/io.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';
import 'package:xiaokeai/services/auth/acc/auth_service.dart';
import 'package:xiaokeai/services/pref/shared_pref_service.dart';
import 'package:xiaokeai/shared/common/file_picker_enum.dart';
import 'package:xiaokeai/shared/services/firebase_storage_enum.dart';

class CloudObjectStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final int _defaultUploadLimit = 10 * 1024 * 1024; // 10 MB
  final SharedPreferencesService _prefs = getIt<SharedPreferencesService>();
  final AuthService _auth = getIt<AuthService>();
  final Logger _logger = locator<Logger>();

  CloudObjectStorageService();

  /// Set custom upload limit
  Future<void> setUploadLimit(int limitInBytes) async {
    await _prefs.setInt('uploadLimit', limitInBytes);
  }

  /// Get current upload limit
  Future<int> getUploadLimit() async {
    return _prefs.getInt('uploadLimit') ?? _defaultUploadLimit;
  }

  /// Upload a file with size check
  ///
  /// returns `[path, downloadUrl]`
  Future<List<String>> uploadFile(String path, PlatformFile file,
      {FirebaseStoragePaths? firebaseStoragePath =
          FirebaseStoragePaths.userContent}) async {
    try {
      final uploadLimit = await getUploadLimit();

      Uint8List? fileBytes;
      int fileSize = file.size;

      // Compress images only if the file is an image
      if (file.extension != null &&
          ['jpg', 'jpeg', 'png'].contains(file.extension!.toLowerCase())) {
        // Compress the image
        fileBytes = await compressImage(file);
        fileSize = fileBytes?.length ?? fileSize;
      } else if (kIsWeb) {
        fileBytes = file.bytes;
      }

      // Check file size against the upload limit
      if (fileSize > uploadLimit) {
        const eMsg = 'File size exceeds the upload limit';
        _logger.e(eMsg, stackTrace: StackTrace.current);
        throw Exception(eMsg);
      }
      _logger.d(firebaseStoragePath!.value);
      final ref = _storage
          .ref(
              "/${firebaseStoragePath.value}/${_auth.getCurrentUserAttributes()!['uid']}/")
          .child(path);
      UploadTask uploadTask;

      if (kIsWeb && fileBytes != null) {
        uploadTask = ref.putData(fileBytes, SettableMetadata());
      } else {
        final fileToUpload = File(file.path!);
        uploadTask = ref.putFile(fileToUpload);
      }

      final snapshot = await uploadTask.whenComplete(() {
        _logger.i("upload task '$path' is completed");
      });
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Cache the file metadata locally
      await _cacheFileMetadata(path, downloadUrl);

      // Store the last update time
      await _updateLastModified(path);

      _logger.d("cached meta data: '$path' -> '$downloadUrl'");

      return [path, downloadUrl];
    } catch (e) {
      _logger.e('Error uploading file: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // Compress an image file
  Future<Uint8List?> compressImage(PlatformFile file) async {
    if (kIsWeb) {
      // web does not use File, directly use Uint8List
      return await FlutterImageCompress.compressWithList(
        file.bytes!,
        quality: 70,
      );
    } else {
      final fileToCompress = File(file.path!);
      return await FlutterImageCompress.compressWithFile(
        fileToCompress.absolute.path,
        quality: 70,
      );
    }
  }

  // Download a file
  Future<String> downloadFile(String path,
      {FirebaseStoragePaths? firebaseStoragePath =
          FirebaseStoragePaths.userContent}) async {
    try {
      if (_isCacheValid(path)) {
        return await _getCachedFileUrl(path) ?? '';
      }

      final ref = _storage
          .ref(
              "/${firebaseStoragePath!.value}/${_auth.getCurrentUserAttributes()!['uid']}/")
          .child(path);
      final url = await ref.getDownloadURL();
      await _cacheFileMetadata(path, url);
      await _updateLastModified(path);
      return url;
    } catch (e) {
      _logger.e('Error downloading file: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// Delete a file
  Future<void> deleteFile(String path,
      {FirebaseStoragePaths firebaseStoragePath =
          FirebaseStoragePaths.userContent}) async {
    Reference? ref;
    try {
      ref = _storage
          .ref(
              "/${firebaseStoragePath.value}/${_auth.getCurrentUserAttributes()!['uid']}/")
          .child(path);
      await ref.delete();
      await _deleteCachedFileMetadata(path);
    } catch (e) {
      _logger.e('Error deleting file: "${e.toString()}" with ref "$ref"',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // delete all files in folder
  Future<void> deleteAllFilesInFolder(
      {FirebaseStoragePaths? firebaseStoragePath =
          FirebaseStoragePaths.userContent}) async {
    final storageRef = _storage.ref(
        "/${firebaseStoragePath!.value}/${_auth.getCurrentUserAttributes()!['uid']}/");
    final folderRef = storageRef.child("uploads");

    try {
      final listResult = await folderRef.listAll();

      final deleteTasks = listResult.items.map((ref) {
        return ref.delete();
      }).toList();
      _logger.d("deleting files in folder: $folderRef");
      await Future.wait(deleteTasks);

      _logger.d('All files in the folder have been deleted.');
    } catch (e) {
      _logger.e('Error deleting files: $e',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // Check for updates and sync if necessary
  Future<void> syncFile(String path,
      {FirebaseStoragePaths firebaseStoragePath =
          FirebaseStoragePaths.userContent}) async {
    try {
      final ref = _storage
          .ref(
              "/${firebaseStoragePath.value}/${_auth.getCurrentUserAttributes()!['uid']}/")
          .child(path);
      final metadata = await ref.getMetadata();
      final lastModified = metadata.updated ?? metadata.timeCreated;
      final localLastModified = await _getLastModified(path);

      if (lastModified != null && lastModified.isAfter(localLastModified)) {
        await downloadFile(path);
      }
    } catch (e) {
      _logger.e('Error syncing file: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // Helper methods for caching metadata
  Future<void> _cacheFileMetadata(String path, String url) async {
    await _prefs.setString('${path}_url', url);
  }

  Future<String?> _getCachedFileUrl(String path) async {
    return _prefs.getString('${path}_url');
  }

  Future<void> _deleteCachedFileMetadata(String path) async {
    await _prefs.removeKey('${path}_url');
    await _prefs.removeKey('${path}_lastModified');
  }

  Future<void> _updateLastModified(String path) async {
    await _prefs.setString(
        '${path}_lastModified', DateTime.now().toIso8601String());
  }

  Future<DateTime> _getLastModified(String path) async {
    final lastModifiedString = _prefs.getString('${path}_lastModified');
    return lastModifiedString != null
        ? DateTime.parse(lastModifiedString)
        : DateTime(1970);
  }

  bool _isCacheValid(String path) {
    return _prefs.containsKey('${path}_url');
  }

  /// Helper method to pick a general file/image (works on both web and mobile)
  Future<PlatformFile?> pickImageOrFile(FilePickerMode pickerMode) async {
    try {
      switch (pickerMode) {
        case FilePickerMode.filePicker:
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            return result.files.single;
          }
          break;

        case FilePickerMode.photoPicker:
          final imagePicker = ImagePicker();
          final pickedFile =
              await imagePicker.pickImage(source: ImageSource.gallery);

          if (pickedFile != null) {
            // Convert the picked image file to PlatformFile
            final fileBytes = await pickedFile.readAsBytes();
            return PlatformFile(
              name: pickedFile.name,
              size: fileBytes.length,
              bytes: fileBytes,
              path: pickedFile.path,
            );
          }
          break;

        default:
          const String eMsg = "Picker mode is not selected";
          _logger.e(eMsg, stackTrace: StackTrace.current);
          throw Exception(eMsg);
      }
    } on PlatformException catch (e) {
      _logger.e('Error picking file or image: [${e.code}]: ${e.message}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e('Error picking file or image: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
    return null;
  }
}
