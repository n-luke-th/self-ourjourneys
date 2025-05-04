/// lib/components/file_picker_preview.dart
///
// lib/components/previews/file_picker_preview.dart

import 'package:flutter/material.dart';
import 'package:ourjourneys/models/storage/selected_file.dart';

class FilePickerPreview extends StatelessWidget {
  final List<SelectedFile> files;
  final void Function(List<SelectedFile>) onSelectedFilesChanged;

  const FilePickerPreview({
    super.key,
    required this.onSelectedFilesChanged,
    required this.files,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: files.map((file) {
        final isImage =
            file.file.extension?.toLowerCase().contains("jpg") == true ||
                file.file.extension?.toLowerCase().contains("png") == true ||
                file.file.extension?.toLowerCase().contains("jpeg") == true;

        return Chip(
          label: Text(file.file.name),
          avatar: isImage
              ? CircleAvatar(
                  backgroundImage: MemoryImage(file.bytes),
                )
              : const CircleAvatar(
                  child: Icon(Icons.insert_drive_file),
                ),
          onDeleted: () {
            final updatedFiles = [...files]..remove(file);
            onSelectedFilesChanged(updatedFiles);
          },
        );
      }).toList(),
    );
  }
}
