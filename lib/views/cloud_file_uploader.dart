/// lib/views/cloud_file_uploader.dart
///
/// a dedicated general purpose file picker and uploader page

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';
import 'package:ourjourneys/services/configs/utils/files_picker_utils.dart';
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
  final CloudFileService _cloudFileService = getIt<CloudFileService>();

  List<PlatformFile> _selectedFiles = [];
  List<String> _uploadedKeys = [];
  List<PlatformFile> _failedFiles = [];

  double _currentFileProgress = 0.0;
  double _overallProgress = 0.0;
  bool _isUploading = false;
  bool _isDone = false;
  String? _statusMessage;

  Future<void> _pickFiles() async {
    final allowedExtensions = [
      ...AllowedExtensions.imageCompactExtensions,
      ...AllowedExtensions.videoExtensions,
      ...AllowedExtensions.documentExtensions,
    ];
    FilePickerResult? result = await FilesPickerUtils.pickFiles(
      allowMultiple: true,
      fileType: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles = result.files.where((f) => f.bytes != null).toList();
        _uploadedKeys = [];
        _failedFiles = [];
        _isUploading = false;
        _isDone = false;
        _statusMessage = null;
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _statusMessage = null;
    });

    List<String> successfulUploadedKeys = [];
    Set<String> failedFilesName = {};
    final totalFiles = _selectedFiles.length;
    int currentUploadFileIndex = 0;

    final fileBytesList = _selectedFiles.map((f) => f.bytes!).toList();
    final fileNames = _selectedFiles.map((f) => f.name).toList();

    final result = await _cloudFileService.uploadMultipleFiles(
      context: context,
      fileBytesList: fileBytesList,
      fileNames: fileNames,
      folderPath: widget.folderPath,
      onSendProgress: (sent, total) {
        setState(() {
          _overallProgress = sent / total;
          _currentFileProgress =
              (currentUploadFileIndex + (_overallProgress)) / totalFiles;
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

    successfulUploadedKeys = result.$1;
    failedFilesName = result.$2;

    setState(() {
      _uploadedKeys = successfulUploadedKeys;
      _isUploading = false;
      _isDone = true;
      _failedFiles = _selectedFiles
          .where((f) => failedFilesName.contains(f.name))
          .toList();
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
❌ Failed/Skipped: $failed ${_failedFiles.isNotEmpty ? "->" : ""} ${_failedFiles.map((f) => f.name).join(', ')}
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
      _selectedFiles = _failedFiles;
      await _uploadFiles();
    }
  }

  Widget _buildFilePreview(PlatformFile file) {
    if (file.bytes == null) return const SizedBox();

    final isImage = file.extension != null &&
        [...AllowedExtensions.imageCompactExtensions]
            .contains(file.extension!.toLowerCase());

    if (isImage) {
      return Image.memory(
        file.bytes!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey.shade200,
        child: Center(
          child: Text(
            file.extension ?? 'file',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: 'Cloud Files Uploader',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isUploading && !_isDone)
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Files'),
            ),
          UiConsts.SizedBoxGapVertical_standard,
          if (_selectedFiles.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _selectedFiles.map((file) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    _buildFilePreview(file),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _selectedFiles.remove(file);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          UiConsts.SizedBoxGapVertical_large,
          if (_selectedFiles.isNotEmpty && !_isUploading)
            ElevatedButton.icon(
              onPressed: _uploadFiles,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload Files'),
            ),
          if (_isUploading) ...[
            const Text("Uploading current file..."),
            LinearProgressIndicator(
              value: _currentFileProgress,
              minHeight: 6,
              color: Colors.blue,
            ),
            Text(
                '${(_currentFileProgress * 100).toStringAsFixed(0)}% of current file'),
            UiConsts.SizedBoxGapVertical_large,
            const Text("Overall progress..."),
            LinearProgressIndicator(
              value: _overallProgress,
              minHeight: 6,
              color: Colors.green,
            ),
            Text('${(_overallProgress * 100).toStringAsFixed(0)}% overall'),
          ],
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
    );
  }
}
