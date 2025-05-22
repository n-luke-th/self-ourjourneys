/// lib/views/albums/new_album_page.dart
///
/// a page where is meant to create new album

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart'
    show FormBuilderValidators;
import 'package:logger/logger.dart';
import 'package:ourjourneys/components/cloud_image.dart';
import 'package:ourjourneys/components/file_picker_preview.dart';
import 'package:ourjourneys/models/storage/selected_file.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/views/albums/album_creation_live_result_page.dart';
import 'package:ourjourneys/components/server_file_selector.dart';
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

  Set<SelectedFile> _selectedLocalFiles = {};
  List<ObjectsData> _selectedServerObjects = [];

  void _onLocalFilesSelected(List<SelectedFile> files,
      {bool isReplacing = false}) {
    _logger
        .d("Picked local files: [${files.map((i) => i.file.name).join(', ')}]");
    setState(() {
      if (!isReplacing) {
        if (_selectedLocalFiles.isNotEmpty) {
          _selectedLocalFiles.addAll(files.where((f) => _selectedLocalFiles
              .where((i) => i.file.name == f.file.name)
              .isEmpty));
        } else {
          _selectedLocalFiles.addAll(files);
        }
      } else {
        _selectedLocalFiles = files.toSet();
      }
    });
    _logger.i(
        "Selected files: [${_selectedLocalFiles.map((i) => i.file.name).join(', ')}]");
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
                    isEmptyAlbum: true,
                    albumName: _nameController.text.trim(),
                    folderPath: "",
                    fileBytesList: [],
                    fileNames: [],
                    selectedExistingObjectKeys: [])));
      }
      // else {
      //   Navigator.pop(context);
      // }
    } else {
      _logger.d(
          "Creating album: '${_nameController.text}' with files: [${_selectedLocalFiles.map((i) => i.file.name).join(', ')}]");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlbumCreationLiveResultPage(
            isEmptyAlbum: false,
            albumName: _nameController.text.trim(),
            folderPath:
                "uploads/${Utils.getUtcTimestampString()}-${_authWrapper.uid}",
            fileBytesList: _selectedLocalFiles.map((f) => f.bytes).toList(),
            fileNames: _selectedLocalFiles.map((e) => e.file.name).toList(),
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
    return mainView(context,
        appBarTitle: "Create New Album",
        persistentFooterAlignment: AlignmentDirectional.center,
        bottomNavigationBar: Padding(
          padding: UiConsts.PaddingAll_large,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_outlined),
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
        floatingActionButtonIcon: Icons.upload_file_outlined,
        floatingActionButtonTooltip: "Add/Edit Media File(s) From Source",
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButtonProps: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        ), onFloatingActionButtonPressed: () {
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
                    "Local Files",
                    textAlign: TextAlign.center,
                  ),
                  onTap: () async => await Utils.pickLocalFiles(
                    onFilesSelected: (List<SelectedFile> pickedFiles) =>
                        _onLocalFilesSelected(pickedFiles),
                    onCompleted: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: UiConsts.BorderRadiusCircular_standard),
                  title: const Text(
                    "Server Files",
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServerFileSelector(
                              selectedFiles: [..._selectedServerObjects],
                              onSelectionChanged:
                                  (List<ObjectsData> selectedObjects) {
                                setState(() {
                                  _selectedServerObjects = selectedObjects;
                                });
                              }),
                        ));
                  },
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
                      _buildTextInputField(),
                      UiConsts.SizedBoxGapVertical_large,
                      ..._buildSelectedLocalFiles(),
                      UiConsts.SizedBoxGapVertical_standard,
                      ..._buildSelectedServerFiles(),
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

  List<Widget> _buildSelectedServerFiles() {
    return [
      Chip(
          backgroundColor: Theme.of(context).colorScheme.secondaryFixed,
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
            borderRadius: UiConsts.BorderRadiusCircular_standard,
          )),
      UiConsts.SizedBoxGapVertical_small,
      Wrap(
        runAlignment: WrapAlignment.spaceAround,
        runSpacing: 10,
        spacing: 10,
        children: [
          ..._selectedServerObjects.map((obj) {
            return Chip(
              avatar: CircleAvatar(
                child: CloudImage(objectKey: obj.objectKey),
              ),
              label: Text(obj.fileName),
              onDeleted: () => _onServerObjectDeleted(obj),
            );
          })
        ],
      ),
    ];
  }

  List<Widget> _buildSelectedLocalFiles() {
    return [
      Chip(
          backgroundColor: Theme.of(context).colorScheme.secondaryFixed,
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
            borderRadius: UiConsts.BorderRadiusCircular_standard,
          )),
      UiConsts.SizedBoxGapVertical_small,
      FilePickerPreview(
        files: [..._selectedLocalFiles],
        onSelectedFilesChanged: (files, {bool isReplacing = false}) =>
            _onLocalFilesSelected(files, isReplacing: isReplacing),
      ),
    ];
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
            labelText: "name",
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
                borderRadius: UiConsts.BorderRadiusCircular_standard,
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                )),
            focusedErrorBorder: UnderlineInputBorder(
              borderRadius: UiConsts.BorderRadiusCircular_standard,
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: UiConsts.BorderRadiusCircular_standard,
              borderSide: BorderSide(color: Theme.of(context).focusColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: UiConsts.BorderRadiusCircular_standard,
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.onPrimary),
            ),
            border: InputBorder.none));
  }
}
