/// lib/components/file_picker_preview.dart
///
/// a widget that shows a preview of selected local files

import 'package:flutter/material.dart';
import 'package:ourjourneys/components/media_item_container.dart';
import 'package:ourjourneys/helpers/utils.dart' show Utils;
import 'package:ourjourneys/models/storage/objects_data.dart';
import 'package:ourjourneys/models/storage/selected_file.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/shared/helpers/misc.dart';
import 'package:ourjourneys/shared/views/screen_sizes.dart' show ScreenSize;
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;
import 'package:ourjourneys/views/albums/full_media_view.dart';

class FilePickerPreview extends StatelessWidget {
  final List<SelectedFile> files;
  final void Function(List<SelectedFile>, {bool isReplacing})?
      onLocalSelectedFilesChanged;
  final void Function(ObjectsData)? onServerObjectDeleted;
  final bool cloudImageAllowCache;

  const FilePickerPreview({
    super.key,
    this.onLocalSelectedFilesChanged,
    this.onServerObjectDeleted,
    this.cloudImageAllowCache = true,
    required this.files,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tightFor(
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: files.isEmpty
            ? MediaQuery.sizeOf(context).height * 0.1
            : MediaQuery.sizeOf(context).height * 0.35,
      ),
      child: GridView.builder(
          itemCount: files.length,
          padding: UiConsts.PaddingAll_standard,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio:
                Utils.getScreenSize(MediaQuery.sizeOf(context).width) ==
                        ScreenSize.large
                    ? 2
                    : 1,
          ),
          itemBuilder: (context, index) {
            final file = files[index];
            final String mimeType =
                file.fetchSourceMethod == FetchSourceMethod.local
                    ? Utils.detectMimeTypeFromFilepath(file.localFile!.name) ??
                        "text/*"
                    : file.cloudObjectData!.contentType;
            return GestureDetector(
              onTap: () async => await _onTabTrackedItem(context,
                  file: file, mimeType: mimeType),
              onLongPress: () async => await _onLongPressTrackedItem(context,
                  file: file, mimeType: mimeType),
              child: MediaItemContainer(
                mimeType: mimeType,
                fetchSourceMethod: file.fetchSourceMethod,
                cloudImageAllowCache: cloudImageAllowCache,
                imageFilterQuality: FilterQuality.low,
                mediaItem: file.fetchSourceMethod == FetchSourceMethod.local
                    ? file.localFile
                    : file.cloudObjectData!.objectThumbnailKey,
                extraMapData: {
                  "description":
                      file.fetchSourceMethod == FetchSourceMethod.local
                          ? file.localFile!.name
                          : file.cloudObjectData!.fileName
                },
                showActionWidget: true,
                showDescriptionBar: false,
                actionWidget: IconButton(
                  color: Colors.red,
                  onPressed: () {
                    if (onLocalSelectedFilesChanged != null &&
                        file.fetchSourceMethod == FetchSourceMethod.local) {
                      onLocalSelectedFilesChanged!([...files]..remove(file),
                          isReplacing: true);
                    } else if (onServerObjectDeleted != null &&
                        file.cloudObjectData != null) {
                      onServerObjectDeleted!(file.cloudObjectData!);
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
                widgetRatio: 1,
                mediaAndDescriptionBarFlexValue: (18, 2),
                mediaRatio: 1,
                fitting: BoxFit.cover,
                shape: BoxShape.rectangle,
              ),
            );
          }),
    );
  }

  Future<dynamic> _onTabTrackedItem(BuildContext context,
      {required SelectedFile file, required String mimeType}) async {
    final int? fileSize = await file.localFile?.length() ??
        file.cloudObjectData?.objectSizeInBytes;
    return Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => FullMediaView(
                fetchSourceMethod: file.fetchSourceMethod,
                onlineObjectKey: file.cloudObjectData?.objectKey,
                localFile: file.localFile,
                allowDownload: false,
                extraMapData: {"fileSizeInBytes": fileSize},
                objectType: Utils.detectFileTypeFromMimeType(mimeType))));
  }

  Future<void> _onLongPressTrackedItem(BuildContext context,
      {required SelectedFile file, required String mimeType}) async {
    await DialogService.showInfoDialog(
        context: context,
        title: "Media information",
        message:
            "Media type: ${Utils.detectFileTypeFromMimeType(mimeType).stringValue}\nName: ${file.localFile?.name ?? file.cloudObjectData?.fileName}");
  }
}
