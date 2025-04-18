/// lib/components/cloud_file_uploader.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';
import 'package:ourjourneys/shared/common/file_picker_enum.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

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

  List<PlatformFile> _files = [];
  List<String> _uploadedKeys = [];
  List<PlatformFile> _failedFiles = [];

  double _currentFileProgress = 0.0;
  double _overallProgress = 0.0;
  bool _isUploading = false;
  bool _isDone = false;
  String? _statusMessage;

  Future<void> _pickAndUploadFiles() async {
    final allowedExtensions = [
      ...AllowedExtensions.imageExtensions,
      // ...AllowedExtensions.audioExtensions,
      ...AllowedExtensions.videoExtensions,
      ...AllowedExtensions.documentExtensions,
    ];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _files = result.files.where((f) => f.bytes != null).toList();
      _uploadedKeys = [];
      _failedFiles = [];
      _isUploading = true;
      _isDone = false;
      _statusMessage = null;
    });

    await _uploadFiles(_files);
  }

  Future<void> _uploadFiles(List<PlatformFile> filesToUpload) async {
    List<String> successfulUploadedKeys = [];
    Set<String> failedFilesName = {};
    final totalFiles = filesToUpload.length;
    int currentUploadFileIndex = 0;

    final fileBytesList = filesToUpload.map((f) => f.bytes!).toList();
    final fileNames = filesToUpload.map((f) => f.name).toList();

    (successfulUploadedKeys, failedFilesName) =
        await _cloudFileService.uploadMultipleFiles(
      context: context,
      fileBytesList: fileBytesList,
      fileNames: fileNames,
      folderPath: widget.folderPath,
      onSendProgress: (sent, total) {
        setState(() {
          _overallProgress = ((sent / total));
          _currentFileProgress =
              (currentUploadFileIndex + (sent / total)) / totalFiles;
        });
      },
      onFileIndexChanged: (int newIndex) {
        setState(() {
          currentUploadFileIndex = newIndex;
          _statusMessage = _buildSummaryText(
            uploaded:
                currentUploadFileIndex == 0 ? 0 : currentUploadFileIndex - 1,
            total: totalFiles,
            failed: _failedFiles.length,
          );
        });
      },
    );

    setState(() {
      _uploadedKeys = successfulUploadedKeys;
      _isUploading = false;
      _isDone = true;
      _failedFiles =
          _failedFiles.where((f) => !failedFilesName.contains(f.name)).toList();
      _statusMessage = _buildSummaryText(
        uploaded: successfulUploadedKeys.length,
        total: totalFiles,
        failed: _failedFiles.length,
      );
    });

    if (widget.onUploaded != null) {
      widget.onUploaded!(_uploadedKeys);
    }
  }

  String _buildSummaryText({
    required int uploaded,
    required int total,
    required int failed,
  }) {
    return '''
✅ Uploaded: $uploaded / $total
❌ Failed: $failed ${_failedFiles.isNotEmpty ? "->" : ""} ${_failedFiles.map((f) => f.name).join(', ')}
📦 Object Keys:
${_uploadedKeys.map((k) => '- $k').join('\n')}
''';
  }

  Future<void> _retryFailedUploads() async {
    if (_failedFiles.isNotEmpty) {
      setState(() {
        _isUploading = true;
        _statusMessage = null;
      });
      await _uploadFiles(_failedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: "Upload Files",
      body: Center(
        child: Padding(
          padding: UiConsts.PaddingAll_large,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isUploading && !_isDone)
                ElevatedButton.icon(
                  onPressed: _pickAndUploadFiles,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select & Upload Files'),
                ),
              if (_isUploading) ...[
                Text("Uploading current file..."),
                LinearProgressIndicator(
                  value: _currentFileProgress,
                  minHeight: 6,
                  color: Colors.blue,
                ),
                Text(
                    '${(_currentFileProgress * 100).toStringAsFixed(0)}% of current file'),
                UiConsts.SizedBoxGapVertical_large,
              ],
              Text("Overall progress..."),
              LinearProgressIndicator(
                value: _overallProgress,
                minHeight: 6,
                color: Colors.green,
              ),
              Text('${(_overallProgress * 100).toStringAsFixed(0)}% overall'),
              // ],
              // if (_isDone && _statusMessage != null)
              if (_statusMessage != null) ...[
                UiConsts.SizedBoxGapVertical_large,
                Text(
                  _statusMessage!,
                  style: const TextStyle(color: Colors.grey),
                ),
                if (_failedFiles.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _retryFailedUploads,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry Failed Files"),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
