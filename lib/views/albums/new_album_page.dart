/// lib/views/albums/new_album_page.dart
///

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart'
    show FormBuilderValidators;
import 'package:logger/logger.dart' show Logger;
import 'package:ourjourneys/components/file_picker_preview.dart';
import 'package:ourjourneys/components/method_components.dart';
import 'package:ourjourneys/helpers/get_platform_service.dart';
import 'package:ourjourneys/models/storage/selected_file.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/shared/helpers/misc.dart' show FetchSourceMethod;
import 'package:ourjourneys/views/albums/album_creation_live_result_page.dart';
import 'package:ourjourneys/components/server_file_selector.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/helpers/utils.dart' show FileUtils, Utils;
import 'package:ourjourneys/models/storage/objects_data.dart' show ObjectsData;
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

/// a page where is meant to create new album
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

  Set<SelectedFile> _selectedLocalFiles = {};
  List<ObjectsData> _selectedServerObjects = [];

  void _onLocalFilesSelected(List<SelectedFile> files,
      {bool isReplacing = false}) {
    _logger.d(
        "Picked local files: [${files.map((i) => i.localFile?.name).join(', ')}]");
    setState(() {
      if (!isReplacing) {
        if (_selectedLocalFiles.isNotEmpty) {
          _selectedLocalFiles.addAll(files.where((f) => _selectedLocalFiles
              .where((i) => i.localFile?.name == f.localFile?.name)
              .isEmpty));
        } else {
          _selectedLocalFiles.addAll(files);
        }
      } else {
        _selectedLocalFiles = files.toSet();
      }
    });
    _logger.i(
        "Tracked files (${_selectedLocalFiles.length}): [${_selectedLocalFiles.map((i) => i.localFile?.name).join(', ')}]");
  }

  void _onServerObjectDeleted(ObjectsData object) {
    setState(() {
      _selectedServerObjects
          .removeWhere((o) => o.objectKey == object.objectKey);
    });
    _logger.d(
        "Deleted server object: [${object.objectKey}] from selected server objects");
  }

  void _onClearServerObject() {
    setState(() {
      _selectedServerObjects.clear();
    });
    _logger.d("Cleared selected server objects");
  }

  void _onClearSelectedLocalFiles() {
    setState(() {
      _selectedLocalFiles.clear();
    });
    _logger.d("Cleared selected local files");
  }

  Future<void> _createAlbum() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocalFiles.isEmpty && _selectedServerObjects.isEmpty) {
      final bool? result = await DialogService.showConfirmationDialog(
          context: context,
          title: "Create empty album?",
          message: "Are you sure to create an empty album?",
          confirmText: "SURE");
      if (result == true) {
        _logger.d("Creating empty album: '${_nameController.text}'");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AlbumCreationLiveResultPage(
                  isNoNeedNewUpload: true,
                  albumName: _nameController.text.trim(),
                  folderPath: "",
                  listOfXFiles: [],
                  selectedExistingObjectKeys: [])),
        );
      }
    } else {
      _logger.i(
          "Creating album: '${_nameController.text}' with files: [${_selectedLocalFiles.map((i) => i.localFile?.name).join(', ')}, ${_selectedServerObjects.map((i) => i.objectKey).join(', ')}]");
      final List<String> fileNames =
          _selectedLocalFiles.map((e) => e.localFile!.name).toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlbumCreationLiveResultPage(
            isNoNeedNewUpload: fileNames.isEmpty ? true : false,
            albumName: _nameController.text.trim(),
            folderPath: Utils.getFolderPath(_authWrapper.uid),
            listOfXFiles: _selectedLocalFiles.map((f) => f.localFile!).toList(),
            selectedExistingObjectKeys:
                _selectedServerObjects.map((e) => e.objectKey).toList(),
          ),
        ),
      );
    }
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
    return PopScope(
      canPop: false,
      child: mainView(context,
          appBarTitle: "Create New Album",
          persistentFooterAlignment: AlignmentDirectional.center,
          appBarLeading: BackButton(
            onPressed: () async {
              await MethodsComponents.showPopPageConfirmationDialog(context);
            },
          ),
          bottomSheet: Padding(
            padding: UiConsts.PaddingAll_large,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined),
              onPressed: () async => _createAlbum(),
              style: ElevatedButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: UiConsts.PaddingAll_large,
                shape: RoundedRectangleBorder(
                  borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
                ),
              ),
              label: const Text("CREATE ALBUM"),
            ),
          ),
          showFloatingActionButton: true,
          floatingActionButtonIcon: Icons.upload_file_outlined,
          floatingActionButtonTooltip: "Add/Edit Media File(s) From Source",
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButtonProps: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          onFloatingActionButtonPressed: () async =>
              await MethodsComponents.showUploadSourceSelector(context,
                  onServerSourceSelected: () => _onServerSourceSelected(),
                  onLocalSourceSelected: () async =>
                      await _onLocalSourceSelected()),
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 560),
                margin: UiConsts.PaddingAll_small,
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
                        _buildTextInputField(),
                        UiConsts.SizedBoxGapVertical_large,
                        _buildSelectedLocalFiles(),
                        UiConsts.SizedBoxGapVertical_standard,
                        _buildSelectedServerFiles(),
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
          )),
    );
  }

  Future<void> _onLocalSourceSelected() async {
    if (PlatformDetectionService.isWeb) {
      await FileUtils.pickLocalFiles(
        onFilesSelected: (List<SelectedFile> pickedFiles) =>
            _onLocalFilesSelected(pickedFiles),
        onCompleted: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      );
    } else if (PlatformDetectionService.isMobile) {
      await FileUtils.pickLocalPhotosOrVideos(
          onMediaSelected: (List<SelectedFile> pickedFiles) {
        _onLocalFilesSelected(pickedFiles);
      }, onCompleted: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _onServerSourceSelected() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServerFileSelector(
              selectedFiles: [..._selectedServerObjects],
              onSelectionChanged: (List<ObjectsData> selectedObjects) {
                setState(() {
                  _selectedServerObjects = selectedObjects;
                });
              }),
        ));
  }

  Widget _buildSelectedServerFiles() {
    final Color backgroundColor = Theme.of(context).colorScheme.secondaryFixed;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
        border: Border.all(
          color: backgroundColor,
        ),
      ),
      child: Column(children: [
        Chip(
            backgroundColor: backgroundColor,
            deleteButtonTooltipMessage: "Clear selected server files",
            deleteIcon: const Icon(
              Icons.delete_outline_outlined,
              size: UiConsts.standardIconSize,
            ),
            deleteIconColor: Theme.of(context).colorScheme.error,
            onDeleted: () => _onClearServerObject(),
            labelPadding: UiConsts.PaddingAll_standard,
            labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryFixed,
                ),
            label: const Text(
              "Server files selected:",
            ),
            shape: RoundedRectangleBorder(
              borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
            )),
        UiConsts.SizedBoxGapVertical_small,
        FilePickerPreview(
            imageAllowCache: true,
            onServerObjectDeleted: (obj) => _onServerObjectDeleted(obj),
            files: _selectedServerObjects.map((objD) {
              return SelectedFile(
                  fetchSourceMethod: FetchSourceMethod.server,
                  cloudObjectData: objD);
            }).toList()),
      ]),
    );
  }

  Widget _buildSelectedLocalFiles() {
    final Color backgroundColor = Theme.of(context).colorScheme.tertiaryFixed;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
        border: Border.all(
          color: backgroundColor,
        ),
      ),
      child: Column(children: [
        Chip(
            backgroundColor: backgroundColor,
            deleteButtonTooltipMessage: "Clear selected local files",
            deleteIcon: const Icon(
              Icons.delete_outline_outlined,
              size: UiConsts.standardIconSize,
            ),
            deleteIconColor: Theme.of(context).colorScheme.error,
            onDeleted: () => _onClearSelectedLocalFiles(),
            labelPadding: UiConsts.PaddingAll_standard,
            labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryFixed,
                ),
            label: const Text(
              "Local files selected:",
            ),
            shape: RoundedRectangleBorder(
              borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
            )),
        UiConsts.SizedBoxGapVertical_small,
        FilePickerPreview(
          imageAllowCache: false,
          files: [..._selectedLocalFiles],
          onLocalSelectedFilesChanged: (files, {bool isReplacing = false}) =>
              _onLocalFilesSelected(files, isReplacing: isReplacing),
        ),
      ]),
    );
  }

  TextFormField _buildTextInputField() {
    return TextFormField(
        key: _nameKey,
        controller: _nameController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        validator: FormBuilderValidators.required(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {},
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.library_books_outlined),
            labelText: "album name",
            hintText: "name",
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            floatingLabelAlignment: FloatingLabelAlignment.center,
            filled: true,
            floatingLabelStyle: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
            errorStyle:
                TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
            errorBorder: UnderlineInputBorder(
                borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                )),
            focusedErrorBorder: UnderlineInputBorder(
              borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
              borderSide: BorderSide(color: Theme.of(context).focusColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.onPrimary),
            ),
            border: InputBorder.none));
  }
}
