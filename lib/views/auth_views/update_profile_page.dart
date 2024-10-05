/// lib/views/auth_views/update_profile_page.dart
///
/// a page where user can update their profile settings
// TODO: edit this page
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:universal_io/io.dart';
import 'package:xiaokeai/components/main_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xiaokeai/components/quick_settings_menu.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/services/auth/acc/auth_wrapper.dart';
import 'package:xiaokeai/shared/views/ui_consts.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    _authWrapper.refreshAttributes();
    _displayNameController.text = _authWrapper.displayName;
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: AppLocalizations.of(context)!.updateProfile.toUpperCase(),
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
                  GestureDetector(
                    onTap: _getImage,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(Icons.add_a_photo,
                              size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                      controller: _displayNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.displayName,
                          labelText: AppLocalizations.of(context)!.displayName,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          floatingLabelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                          errorStyle: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inverseSurface),
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
                            borderSide:
                                BorderSide(color: Theme.of(context).focusColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                UiConsts.BorderRadiusCircular_standard,
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          border: InputBorder.none),
                      validator: FormBuilderValidators.maxLength(24)),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async => _updateProfile(),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!
                        .updateProfile
                        .toUpperCase()),
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
      await _authWrapper.handleUpdateUserAccountProfile(
          context, _displayNameController.text);
      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }
}
