/// lib/views/auth_views/update_profile_page.dart
///
// TODO: edit this page
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart'
    show FormBuilderValidators;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart' show Logger;
import 'package:universal_io/io.dart' show File;

import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/quick_settings_menu.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

/// a page where user can update their profile settings
///
/// as of now, only the display name can be updated
/// the profile picture is not yet supported
class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final Logger _logger = getIt<Logger>();
  File? _image;
  XFile? _picToBeUploaded;

  @override
  void initState() {
    super.initState();
    _authWrapper.refreshAttributes();
    _displayNameController.text = _authWrapper.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: "UPDATE PROFILE",
      appBarBackgroundColor: Colors.transparent,
      appbarActions: [QuickSettingsMenu()],
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
              Theme.of(context).colorScheme.tertiaryContainer
            ],
          ),
        ),
        child: SizedBox.expand(
          child: Padding(
            padding: UiConsts.PaddingAll_large,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // GestureDetector(
                  //   onTap: _getImage,
                  //   onDoubleTap: _deleteImage,
                  //   child: ClipOval(
                  //     child: _renderImage(),
                  //   ),
                  // ),
                  UiConsts.SizedBoxGapVertical_large,
                  TextFormField(
                      controller: _displayNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                          hintText: "display name",
                          labelText: "display name",
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          floatingLabelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                          errorStyle: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface),
                          errorBorder: UnderlineInputBorder(
                              borderRadius:
                                  UiConsts.BorderRadiusCircular_mediumLarge,
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              )),
                          focusedErrorBorder: UnderlineInputBorder(
                            borderRadius:
                                UiConsts.BorderRadiusCircular_mediumLarge,
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                UiConsts.BorderRadiusCircular_mediumLarge,
                            borderSide:
                                BorderSide(color: Theme.of(context).focusColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                UiConsts.BorderRadiusCircular_mediumLarge,
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          border: InputBorder.none),
                      validator: FormBuilderValidators.maxLength(24)),
                  UiConsts.SizedBoxGapVertical_large,
                  ElevatedButton(
                    onPressed: () async => _updateProfile(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      padding: UiConsts.PaddingElevBtn,
                      shape: RoundedRectangleBorder(
                        borderRadius: UiConsts.BorderRadiusCircular_mediumLarge,
                      ),
                    ),
                    child: const Text("UPDATE PROFILE"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    context.loaderOverlay.show();
    if (_formKey.currentState!.validate()) {
      await _authWrapper.handleUpdateDisplayName(
          context, _displayNameController);
      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }
}
