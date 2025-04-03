/// lib/views/auth_views/update_profile_page.dart
///
/// a page where user can update their profile settings
// TODO: edit this page
// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';
import 'package:xiaokeai/components/main_view.dart';
import 'package:xiaokeai/l10n/generated/i18n/app_localizations.dart'
    show AppLocalizations;
import 'package:xiaokeai/components/quick_settings_menu.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/helpers/get_platform_service.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';
import 'package:xiaokeai/services/auth/acc/auth_wrapper.dart';
import 'package:xiaokeai/services/dialog/dialog_service.dart';
import 'package:xiaokeai/services/notifications/notification_manager.dart';
import 'package:xiaokeai/services/notifications/notification_service.dart';
import 'package:xiaokeai/services/object_storage/cloud_object_storage_wrapper.dart';
import 'package:xiaokeai/shared/common/file_picker_enum.dart';
import 'package:xiaokeai/shared/helpers/platform_enum.dart';
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
  final _platformDetectionService = PlatformDetectionService();
  final _cloudObjectStorageWrapper = getIt<CloudObjectStorageWrapper>();
  final Logger _logger = locator<Logger>();
  File? _image;
  PlatformFile? _picToBeUploaded;

  @override
  void initState() {
    super.initState();
    _authWrapper.refreshAttributes();
    _displayNameController.text = _authWrapper.displayName;
  }

  Future<void> _getImage() async {
    final pickedFile = await _cloudObjectStorageWrapper
        .handlePickImageOrFile(FilePickerMode.photoPicker);
    if (pickedFile != null) {
      setState(() {
        _picToBeUploaded = pickedFile;
        switch (_platformDetectionService.currentPlatform) {
          case PlatformEnum.web:
            _image = File.fromRawPath(pickedFile.bytes!);
            break;
          case PlatformEnum.android || PlatformEnum.iOS:
            _image = File(pickedFile.path!);
            break;
          default:
          // TODO: throws global error
        }
      });
    }
  }

  Future<void> _deleteImage() async {
    // TODO: localize this
    _authWrapper.refreshAttributes();
    if (_image != null || _authWrapper.profilePicURL != '') {
      final bool? confirmed = await DialogService.showConfirmationDialog(
          context: context,
          title: "Delete this profile picture?",
          message: AppLocalizations.of(context)!
              .deleteThisProfilePicConfirmationMessage,
          confirmText: AppLocalizations.of(context)!.continueTxt.toUpperCase());
      if (confirmed == true) {
        context.loaderOverlay.show();
        setState(() {
          CachedNetworkImage.evictFromCache(_authWrapper.profilePicURL);

          _image = null;
        });
        await _authWrapper.handleRemoveProfilePic(context);
      }
    } else {
      context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: AppLocalizations.of(context)!.warning,
              message: AppLocalizations.of(context)!.noProfilePicToDelete,
              type: CustomNotificationType.warning));
    }
    context.loaderOverlay.hide();
  }

  Widget _renderImage() {
    setState(() {
      _authWrapper.refreshAttributes();
      // _photoURL = _authWrapper.profilePicURL;
    });
    // _logger.w("------ ${_authWrapper.profilePicURL}");
    var imageHolder = _image == null
        ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
        : SizedBox(
            child: Image.file(
              _image!,
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
          );
    var networkImageHolder = CachedNetworkImage(
      imageUrl: _authWrapper.profilePicURL,
      width: 100.0,
      height: 100.0,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
      errorWidget: (context, url, error) {
        // TODO: throw global error here
        _logger.e("error loading img: '${error.toString()}' from '$url'",
            error: error, stackTrace: StackTrace.current);
        return const Icon(Icons.error);
      },
    );
    if ((_authWrapper.profilePicURL == "_Unauthenticated user_") ||
        (_authWrapper.profilePicURL == '')) {
      return imageHolder;
    } else if (_image == null) {
      if ((_authWrapper.profilePicURL == "_Unauthenticated user_") ||
          (_authWrapper.profilePicURL == '')) {
        return imageHolder;
      } else {
        return networkImageHolder;
      }
    } else if (_image != null) {
      return imageHolder;
    } else {
      return networkImageHolder;
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
                    onDoubleTap: _deleteImage,
                    child: ClipOval(
                      child: _renderImage(),
                    ),
                  ),
                  UiConsts.SizedBoxGapVertical_large,
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
                        borderRadius: UiConsts.BorderRadiusCircular_standard,
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
          context, _displayNameController.text, _picToBeUploaded);
      context.loaderOverlay.hide();
    }
    context.loaderOverlay.hide();
  }
}
