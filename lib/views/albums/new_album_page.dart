/// lib/views/albums/new_album_page.dart
///
/// a page where is meant to create new album

// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data' show Uint8List;

import 'package:file_picker/file_picker.dart' show FileType;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart'
    show FormBuilderValidators;
import 'package:logger/logger.dart';
import 'package:ourjourneys/components/file_picker_preview.dart';
import 'package:ourjourneys/models/storage/selected_file.dart';
import 'package:ourjourneys/services/configs/utils/files_picker_utils.dart';
import 'package:ourjourneys/shared/common/file_picker_enum.dart';
import 'package:ourjourneys/views/albums/album_creation_live_result_page.dart';
import 'package:ourjourneys/components/existing_file_selector.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/helpers/utils.dart';
import 'package:ourjourneys/models/storage/objects_data.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/bottom_sheet/bottom_sheet_service.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class NewAlbumPage extends StatefulWidget {
  const NewAlbumPage({super.key});

  @override
  State<NewAlbumPage> createState() => _NewAlbumPageState();
}

class _NewAlbumPageState extends State<NewAlbumPage> {
  final Logger _logger = getIt<Logger>();
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();

  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _nameController = TextEditingController();

  List<SelectedFile> _selectedFiles = [];
  List<ObjectsData> _selectedExistingObjects = [];

  Future<void> _pickLocalFiles() async {
    final result = await FilesPickerUtils.pickFiles(
      allowMultiple: true,
      fileType: FileType.custom,
      allowedExtensions: [
        ...AllowedExtensions.imageCompactExtensions,
        ...AllowedExtensions.videoExtensions,
      ],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files
        .where((f) => f.bytes != null)
        .map((f) => SelectedFile(file: f, bytes: f.bytes!))
        .toList();

    setState(() => _selectedFiles.addAll(picked));
    _logger.d("Picked files: [${picked.map((i) => i.file.name).join(', ')}]");
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _onFilesSelected(List<SelectedFile> files) {
    setState(() => _selectedFiles = files);
  }

  Future<void> _createAlbum() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFiles.isEmpty) {
      return;
    }
    _logger.d(
        "Creating album: '${_nameController.text}' with files: [${_selectedFiles.map((i) => i.file.name).join(', ')}]");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumCreationLiveResultPage(
          albumName: _nameController.text,
          folderPath:
              "uploads/${Utils.getUtcTimestampString()}-${_authWrapper.uid}",
          fileBytesList: _selectedFiles.map((f) => f.bytes).toList(),
          fileNames: _selectedFiles.map((e) => e.file.name).toList(),
          selectedExistingObjectKeys:
              _selectedExistingObjects.map((e) => e.objectKey).toList(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _authWrapper.refreshUid();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: "Create New Album",
        persistentFooterAlignment: AlignmentDirectional.center,
        bottomNavigationBar: Padding(
          padding: UiConsts.PaddingAll_large,
          child: ElevatedButton.icon(
            icon: Icon(Icons.save_outlined),
            onPressed: () async => _createAlbum(),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              padding: UiConsts.PaddingAll_large,
              shape: RoundedRectangleBorder(
                borderRadius: UiConsts.BorderRadiusCircular_standard,
              ),
            ),
            label: const Text("CREATE ALBUM"),
          ),
        ),
        showFloatingActionButton: true,
        floatingActionButtonIcon: Icons.add_photo_alternate_outlined,
        floatingActionButtonTooltip: "Add Photo",
        onFloatingActionButtonPressed: () {
      // TODO: implement add photo
      BottomSheetService.showCustomBottomSheet(
          context: context,
          initialChildSize: 0.3,
          builder: (context, scrollController) {
            return Column(
              children: [
                const Text("Select File Source"),
                const Divider(),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: UiConsts.BorderRadiusCircular_standard),
                  title: const Text(
                    "Existing Files",
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExistingFileSelector(
                              onSelectionChanged:
                                  (List<ObjectsData> selectedObjects) {
                            setState(() {
                              _selectedExistingObjects = selectedObjects;
                            });
                          }),
                        ));
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: UiConsts.BorderRadiusCircular_standard),
                  title: const Text(
                    "Local Files",
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => _pickLocalFiles(),
                ),
              ],
            );
          });
    },
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxWidth: 550),
              margin: UiConsts.PaddingAll_large,
              transformAlignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: UiConsts.PaddingAll_large,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UiConsts.SizedBoxGapVertical_large,
                      TextFormField(
                          key: _nameKey,
                          controller: _nameController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          validator: FormBuilderValidators.required(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.library_books_outlined),
                              labelText: "name",
                              hintText: "name",
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                              filled: true,
                              floatingLabelStyle: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                              errorStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface),
                              errorBorder: UnderlineInputBorder(
                                  borderRadius:
                                      UiConsts.BorderRadiusCircular_standard,
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  )),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderRadius:
                                    UiConsts.BorderRadiusCircular_standard,
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    UiConsts.BorderRadiusCircular_standard,
                                borderSide: BorderSide(
                                    color: Theme.of(context).focusColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    UiConsts.BorderRadiusCircular_standard,
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              border: InputBorder.none)),
                      UiConsts.SizedBoxGapVertical_large,
                      FilePickerPreview(
                        files: _selectedFiles,
                        onSelectedFilesChanged: (files) =>
                            _onFilesSelected(files),
                      ),
                      UiConsts.SizedBoxGapVertical_large,
                      const Divider(
                        color: Colors.grey,
                        height: 1,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
