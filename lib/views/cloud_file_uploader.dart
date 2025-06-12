/// lib/views/cloud_file_uploader.dart
///

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:logger/logger.dart' show Logger;
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/media_item_container.dart';
import 'package:ourjourneys/components/method_components.dart'
    show MethodsComponents;
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/helpers/utils.dart' show FileUtils;
import 'package:ourjourneys/models/interface/image_display_configs_model.dart';
import 'package:ourjourneys/models/storage/fetch_source_data.dart';
import 'package:ourjourneys/services/cloud/cloud_file_service.dart';
import 'package:ourjourneys/shared/common/allowed_extensions.dart'
    show AllowedExtensions;
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

/// a dedicated general purpose file picker and uploader page
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
  final Logger _logger = getIt<Logger>();

  List<XFile> _selectedFiles = [];
  List<String> _uploadedKeys = [];
  List<XFile> _failedFiles = [];

  double _currentFileProgress = 0.0;
  double _overallProgress = 0.0;
  bool _isUploading = false;
  bool _isDone = false;
  String? _statusMessage;

  void _onLocalFilesSelected(List<XFile> files, {bool isReplacing = false}) {
    _logger.d("Picked local files: [${files.map((i) => i.name).join(', ')}]");
    setState(() {
      if (!isReplacing) {
        if (_selectedFiles.isNotEmpty) {
          _selectedFiles.addAll(files.where(
              (f) => _selectedFiles.where((i) => i.name == f.name).isEmpty));
        } else {
          _selectedFiles.addAll(files);
        }
      } else {
        _selectedFiles = files.toList();
      }
      _uploadedKeys = [];
      _failedFiles = [];
      _isUploading = false;
      _isDone = false;
      _statusMessage = null;
    });
    _logger.i(
        "Tracked files (${_selectedFiles.length}): [${_selectedFiles.map((i) => i.name).join(', ')}]");
  }

  Future<void> _pickFiles() async {
    final allowedExtensions = [
      ...AllowedExtensions.imageCompactExtensions,
      ...AllowedExtensions.videoExtensions,
      ...AllowedExtensions.documentExtensions,
    ];
    await FileUtils.pickLocalFiles(
        onFilesSelected: (selectedFiles) {
          if (selectedFiles.isNotEmpty) {
            _onLocalFilesSelected(selectedFiles
                .map((f) => f.localFile)
                .whereType<XFile>()
                .toList());
          }
        },
        allowedExtensions: allowedExtensions);
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

    final fileBytesList =
        await Future.wait(_selectedFiles.map((f) => f.readAsBytes()).toList());
    final fileNames = _selectedFiles.map((f) => f.name).toList();

    final result = await _cloudFileService.uploadMultipleFiles(
      // ignore: use_build_context_synchronously
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
    _logger.d("Retrying failed uploads");
    if (_failedFiles.isNotEmpty) {
      setState(() {
        _isUploading = true;
        _statusMessage = null;
      });
      _selectedFiles = _failedFiles;
      await _uploadFiles();
    }
  }

  Widget _buildFilePreview(XFile file) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.4,
      child: MediaItemContainer(
        mimeType: file.mimeType ??
            FileUtils.detectMimeTypeFromFilepath(file.path) ??
            "",
        imageRendererConfigs:
            ImageDisplayConfigsModel(filterQuality: FilterQuality.low),
        fetchSourceData: FetchSourceData(
            fetchSourceMethod: FetchSourceMethod.local, localFile: file),
        showActionWidget: true,
        actionWidget: IconButton.outlined(
          icon: const Icon(Icons.close, size: 18, color: Colors.red),
          onPressed: () {
            setState(() {
              _selectedFiles.remove(file);
            });
          },
        ),
        showDescriptionBar: true,
        descriptionTxtMaxLines: 1,
        mediaAndDescriptionBarFlexValue: (8, 2),
        extraMapData: {"description": file.name},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: mainView(
        context,
        appBarTitle: 'Cloud Files Uploader',
        appBarLeading: BackButton(
          onPressed: () async {
            if (!_isDone) {
              await MethodsComponents.showPopPageConfirmationDialog(context);
            } else {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
        ),
        bottomSheet: (_selectedFiles.isNotEmpty && !_isUploading && !_isDone)
            ? ElevatedButton.icon(
                onPressed: _uploadFiles,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Start Upload Files'),
              )
            : null,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              _buildSelectFilesMedium(),
              _buildPreviewsOrProgressReport(),
              if (_statusMessage != null) ...[
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: UiConsts.PaddingAll_standard,
                    child: Text(
                      _statusMessage!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                if (_failedFiles.isNotEmpty) _buildRetryBtn(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Align _buildPreviewsOrProgressReport() {
    return Align(
      alignment: Alignment.center,
      child: (!_isUploading && !_isDone && _selectedFiles.isNotEmpty)
          ? Container(
              height: MediaQuery.sizeOf(context).height * 0.5,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.5),
                borderRadius: UiConsts.BorderRadiusCircular_standard,
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _selectedFiles.length,
                shrinkWrap: true,
                padding: UiConsts.PaddingAll_small,
                itemBuilder: (_, int index) {
                  return _buildFilePreview(_selectedFiles[index]);
                },
              ),
            )
          : (_isUploading)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    Text(
                        '${(_overallProgress * 100).toStringAsFixed(0)}% overall'),
                  ],
                )
              : null,
    );
  }

  Widget _buildRetryBtn() {
    {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: UiConsts.PaddingAll_large,
          child: ElevatedButton.icon(
            onPressed: _retryFailedUploads,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry Failed Files"),
          ),
        ),
      );
    }
  }

  Widget _buildSelectFilesMedium() {
    return Align(
      alignment: Alignment.topCenter,
      child: (!_isUploading && !_isDone)
          ? ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Files'),
            )
          : null,
    );
  }
}
