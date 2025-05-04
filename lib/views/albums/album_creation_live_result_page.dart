/// lib/views/albums/album_creation_live_result_page.dart
/// a page to upload objects & create the album, and
/// display the live status of album creation
/// including uploading files
// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data' show Uint8List;

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/utils.dart';
import 'package:ourjourneys/models/db/albums_model.dart';
import 'package:ourjourneys/models/modification_model.dart';
import 'package:ourjourneys/models/storage/objects_data.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';
import 'package:ourjourneys/services/db/firestore_wrapper.dart';
import 'package:ourjourneys/shared/services/firestore_commons.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class AlbumCreationLiveResultPage extends StatefulWidget {
  final String albumName;
  final String folderPath;
  final List<Uint8List> fileBytesList;
  final List<String> fileNames;
  final List<String> selectedExistingObjectKeys;

  const AlbumCreationLiveResultPage({
    super.key,
    required this.folderPath,
    required this.fileBytesList,
    required this.fileNames,
    required this.selectedExistingObjectKeys,
    required this.albumName,
  });

  @override
  State<AlbumCreationLiveResultPage> createState() =>
      _AlbumCreationLiveResultPageState();
}

class _AlbumCreationLiveResultPageState
    extends State<AlbumCreationLiveResultPage> {
  final CloudFileService _cloudFileService = getIt<CloudFileService>();
  final FirestoreWrapper _firestoreWrapper = getIt<FirestoreWrapper>();
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();

  double _currentProgress = 0.0;
  int _currentIndex = 0;
  bool _isUploading = true;
  bool _isAlbumCreated = false;
  Set<String> _uploadedKeys = {};
  List<String> _failedFileNames = [];
  String? _albumDocId;

  @override
  void initState() {
    super.initState();
    _authWrapper.refreshUid();
    _startUploadAndAlbumCreation();
  }

  Future<void> _startUploadAndAlbumCreation() async {
    // final total = widget.fileBytes.length;
    // final uploadedKeys = <String>[];

    final (successful, failedSet) = await _cloudFileService.uploadMultipleFiles(
      context: context,
      fileBytesList: widget.fileBytesList,
      fileNames: widget.fileNames,
      folderPath: widget.folderPath,
      onSendProgress: (sent, totalBytes) {
        setState(() {
          _currentProgress = (sent / totalBytes);
        });
      },
      onFileIndexChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );

    setState(() {
      _uploadedKeys.addAll(successful);
      _failedFileNames = failedSet.toList();
      _isUploading = false;
    });

    if (_uploadedKeys.isNotEmpty ||
        widget.selectedExistingObjectKeys.isNotEmpty) {
      await _createAlbumWithMetadata();
    }
  }

  Future<void> _updateReferencedObjects(
      {required List<String> uploadedObjectKeys}) async {
    for (int i = 0; i < uploadedObjectKeys.length; i++) {
      final objectKey = uploadedObjectKeys[i];
      final ObjectsData objectData = await _firestoreWrapper
          .getDocumentById(
            FirestoreCollections.objectsData,
            Utils.reformatObjectKey(objectKey),
          )
          .then((doc) => doc.data() as Map<String, dynamic>)
          .then((map) => ObjectsData.fromMap(map));
      ObjectsData updatedObjectData = objectData;
      updatedObjectData.linkedAlbums.add(_albumDocId!);

      await _firestoreWrapper.handleUpdateDocument(context,
          collectionName: FirestoreCollections.objectsData,
          docId: Utils.reformatObjectKey(objectKey),
          data: updatedObjectData.toMap(),
          suppressNotification: true);
    }
  }

  Future<void> _createAlbumWithMetadata() async {
    final Timestamp now = Timestamp.now();
    ModificationData updatedModificationData = ModificationData(
        createdByUserId: _authWrapper.uid,
        createdAt: now,
        lastModifiedByUserId: _authWrapper.uid,
        lastModifiedAt: now);
    final albumData = AlbumsModel(
      albumName: widget.albumName,
      modificationData: updatedModificationData,
      id: '',
      linkedObjects: [..._uploadedKeys, ...widget.selectedExistingObjectKeys],
    );

    final albumRef = await _firestoreWrapper.handleCreateDocument(context,
        collectionName: FirestoreCollections.albums,
        data: albumData.toMap(),
        suppressNotification: true);

    setState(() {
      _isAlbumCreated = true;
      _albumDocId = albumRef?.id;
    });
    if (_albumDocId != null) {
      await _updateReferencedObjects(uploadedObjectKeys: [
        ..._uploadedKeys,
        ...widget.selectedExistingObjectKeys
      ]);
    }
  }

  Future<void> _retryFailedUploads() async {
    final retryIndices = widget.fileNames
        .asMap()
        .entries
        .where((entry) => _failedFileNames.contains(entry.value))
        .map((e) => e.key)
        .toList();

    final retryBytes =
        retryIndices.map((i) => widget.fileBytesList[i]).toList();
    final retryNames = retryIndices.map((i) => widget.fileNames[i]).toList();

    setState(() {
      _isUploading = true;
      _failedFileNames = [];
    });

    final (successful, failedSet) = await _cloudFileService.uploadMultipleFiles(
      context: context,
      fileBytesList: retryBytes,
      fileNames: retryNames,
      folderPath: widget.folderPath,
      onSendProgress: (sent, totalBytes) {
        setState(() {
          _currentProgress = (sent / totalBytes);
        });
      },
      onFileIndexChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );

    setState(() {
      _uploadedKeys.addAll(successful);
      _failedFileNames = failedSet.toList();
      _isUploading = false;
    });

    if (!_isAlbumCreated) {
      await _createAlbumWithMetadata();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = !_isUploading && _isAlbumCreated;

    return mainView(
      context,
      appBarTitle: "Album Creation Progress",
      appBarLeading: isDone
          ? null
          : BackButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
      automaticallyImplyLeading: false,
      body: Padding(
        padding: UiConsts.PaddingAll_large,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isUploading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Uploading file ${_currentIndex + 1}/${widget.fileNames.length}"),
                  LinearProgressIndicator(value: _currentProgress),
                  UiConsts.SizedBoxGapVertical_standard,
                ],
              ),
            if (isDone) ...[
              const Text("✅ Album created successfully!",
                  style: TextStyle(fontSize: 18)),
              if (_albumDocId != null)
                Text("Album ID: $_albumDocId",
                    style: const TextStyle(color: Colors.grey)),
              UiConsts.SizedBoxGapVertical_standard,
              ElevatedButton.icon(
                  onPressed: () => context.goNamed("AlbumsPage"),
                  label: const Text("Go to Albums Page"),
                  icon: const Icon(Icons.auto_awesome_mosaic_outlined))
            ],
            if (_failedFileNames.isNotEmpty) ...[
              UiConsts.SizedBoxGapVertical_standard,
              const Text("❌ Failed Files:",
                  style: TextStyle(color: Colors.red)),
              ..._failedFileNames.map((f) =>
                  Text("- $f", style: const TextStyle(color: Colors.red))),
              UiConsts.SizedBoxGapVertical_standard,
              ElevatedButton.icon(
                onPressed: _retryFailedUploads,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry Failed Uploads"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
