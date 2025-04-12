/// lib/components/cloud_file_uploader.dart
import 'dart:typed_data' show Uint8List;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';

class CloudFileUploader extends StatefulWidget {
  final String folderPath;
  final void Function(List<String> uploadedUrls)? onUploaded;

  const CloudFileUploader({
    super.key,
    required this.folderPath,
    this.onUploaded,
  });

  @override
  State<CloudFileUploader> createState() => _CloudFileUploaderState();
}

class _CloudFileUploaderState extends State<CloudFileUploader> {
  final CloudFileService _cloudFileService = CloudFileService();

  double _uploadProgress = 0.0;
  bool _isUploading = false;
  String? _statusMessage;

  Future<void> _pickAndUploadFiles() async {
    setState(() {
      _uploadProgress = 0.0;
      _isUploading = true;
      _statusMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'mp4',
          'mov',
          'avi',
          'txt',
          'json',
          'pdf'
        ],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final fileBytesList = <Uint8List>[];
      final fileNames = <String>[];

      for (final file in result.files) {
        if (file.bytes != null && file.name.isNotEmpty) {
          fileBytesList.add(file.bytes!);
          fileNames.add(file.name);
        }
      }

      int uploadedCount = 0;
      final totalFiles = fileBytesList.length;

      final uploadedUrls = <String>[];

      for (int i = 0; i < totalFiles; i++) {
        final fileBytes = fileBytesList[i];
        final fileName = fileNames[i];

        final url = await _cloudFileService.uploadFile(
          fileBytes: fileBytes,
          fileName: fileName,
          folderPath: widget.folderPath,
          onSendProgress: (sent, total) {
            setState(() {
              _uploadProgress = (uploadedCount + (sent / total)) / totalFiles;
            });
          },
        );

        if (url != null) {
          uploadedUrls.add(url);
          uploadedCount++;
        }

        setState(() {
          _uploadProgress = uploadedCount / totalFiles;
        });
      }

      setState(() {
        _isUploading = false;
        _statusMessage =
            '${uploadedUrls.length} of $totalFiles file(s) uploaded.';
      });

      if (widget.onUploaded != null) {
        widget.onUploaded!(uploadedUrls);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Upload failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickAndUploadFiles,
          icon: const Icon(Icons.upload_file),
          label: const Text('Select & Upload Files'),
        ),
        if (_isUploading || _uploadProgress > 0.0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 4),
                Text('${(_uploadProgress * 100).toStringAsFixed(0)}% uploaded'),
              ],
            ),
          ),
        if (_statusMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _statusMessage!,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
