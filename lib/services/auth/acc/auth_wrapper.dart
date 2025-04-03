/// lib/services/auth/acc/auth_wrapper.dart
/// the authentication wrapper functions
/// are the top-level functions that will perform
/// neccessary auth actions called when user trigger call to action btn (login btn, send password reset email, etc.)

// ignore_for_file: use_build_context_synchronously
// TODO: edit this auth wrapper
// TODO: localize this file

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:xiaokeai/errors/auth_exception/auth_exception.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';
import 'package:xiaokeai/services/auth/acc/auth_service.dart';
import 'package:xiaokeai/services/dialog/dialog_service.dart';
import 'package:xiaokeai/services/notifications/notification_manager.dart';
import 'package:xiaokeai/services/notifications/notification_service.dart';
import 'package:xiaokeai/l10n/generated/i18n/app_localizations.dart'
    show AppLocalizations;
import 'package:xiaokeai/services/object_storage/cloud_object_storage_wrapper.dart';
import 'package:xiaokeai/shared/services/firebase_storage_enum.dart';
import 'package:xiaokeai/views/auth_views/email_sent_page.dart';

class AuthWrapper {
  final Logger _logger = locator<Logger>();
  final AuthService _auth = getIt<AuthService>();
  final CloudObjectStorageWrapper _cloudObjectStorageWrapper =
      getIt<CloudObjectStorageWrapper>();
  String _errorMessage = "";
  String _displayName = "_Unauthenticated user_";
  String _emailAddress = "_Unauthenticated user_";
  String _profilePicURL = "_Unauthenticated user_";

  String get displayName => _displayName;
  String get emailAddress => _emailAddress;
  String get profilePicURL => _profilePicURL;

  AuthWrapper();

  void refreshAttributes() {
    if (_auth.isUserLoggedIn()) {
      _displayName = _auth.getCurrentUserAttributes()!['displayName'] == null
          ? _auth.getCurrentUserAttributes()!['email'].toString()
          : _auth.getCurrentUserAttributes()!['displayName'].toString();
      _profilePicURL = _auth.getCurrentUserAttributes()!['photoURL'] ?? "";
      _emailAddress = _auth.getCurrentUserAttributes()!['email'].toString();
    } else {
      _displayName = "_Unauthenticated user_";
      _profilePicURL = "_Unauthenticated user_";
      _emailAddress = "Unauthenticated user_";
    }
  }

  /// Retreives all available user attributes from Firebase
  ///
  /// wrapper of the method from auth service
  Map<String, dynamic>? getCurrentUserAttributes() {
    try {
      return _auth.getCurrentUserAttributes();
    } catch (e) {
      _logger.e('Unable to get current user attributes: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
    }
    return null;
  }

  Future<void> handleLogout(BuildContext context) async {
    final bool? confirmed = await DialogService.showConfirmationDialog(
      context: context,
      title: AppLocalizations.of(context)!.logoutConfirmationTitle,
      message: AppLocalizations.of(context)!.logoutConfirmationMessage,
      confirmText: AppLocalizations.of(context)!.logout,
    );
    if (confirmed == true) {
      context.loaderOverlay.show();
      await _auth.signOut();
      context.goNamed('AuthFlow');
      context.loaderOverlay.hide();
    }
  }

  // Future<void> handleRegister(
  //     BuildContext context,
  //     TextEditingController emailController,
  //     TextEditingController passwordController) async {
  //   try {
  //     await _auth.registerWithEmailAndPassword(
  //       emailController.text.trim(),
  //       passwordController.text,
  //     );
  //     context.read<NotificationManager>().showNotification(
  //           context,
  //           NotificationData(
  //               title: AppLocalizations.of(context)!.success,
  //               message: 'Registration successful, you may now login!',
  //               type: CustomNotificationType.success),
  //         );
  //     _logger.d('register success!');
  //     context.pushNamed("Login");
  //   } on AuthException catch (e) {
  //     _errorMessage = e.toString();
  //     context.read<NotificationManager>().showNotification(
  //           context,
  //           NotificationData(
  //               title: AppLocalizations.of(context)!.failed,
  //               message: _errorMessage,
  //               type: CustomNotificationType.error),
  //         );
  //   }
  // }

  // Future<void> handleContinueWithGG(BuildContext context) async {
  //   _logger.i("user selected to continue with Google");
  //   try {
  //     await _auth.continueWithGoogle();
  //     refreshAttributes();
  //     context.read<NotificationManager>().showNotification(
  //           context,
  //           NotificationData(
  //               title: 'Success',
  //               message: "Welcome back, $_displayName",
  //               type: CustomNotificationType.success),
  //         );
  //     _logger.d("continue with Google success!");
  //     _logger
  //         .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
  //     context.pushReplacementNamed('AuthFlow');
  //   } on AuthException catch (e) {
  //     _errorMessage = e.toString();
  //     context.read<NotificationManager>().showNotification(
  //           context,
  //           NotificationData(
  //               title: AppLocalizations.of(context)!.failed,
  //               message: _errorMessage,
  //               type: CustomNotificationType.error),
  //         );
  //   }
  // }

  Future<void> handleSignIn(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) async {
    _logger.d("user selected to login with native provider");
    try {
      await _auth.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );
      refreshAttributes();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.loggedIn,
                message:
                    "${AppLocalizations.of(context)!.welcomeBackWithDisplayNameNext}$_displayName",
                type: CustomNotificationType.success),
          );
      _logger.d("user: '$_displayName' login success!");
      _logger
          .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
      context.pushReplacementNamed('AuthFlow');
    } on AuthException catch (e) {
      _errorMessage = e.toString();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.failed,
                message: _errorMessage,
                type: CustomNotificationType.error),
          );
    } finally {
      context.loaderOverlay.hide();
    }
  }

  // Future<void> handleReauthWithGG(BuildContext context) async {
  //   _logger.d("user selected to reauth with Google");
  //   try {
  //     await _auth.reauthenticateUserWithGoogle();
  //     refreshAttributes();
  //     context.read<NotificationManager>().showNotification(
  //           context,
  //           NotificationData(
  //               title: AppLocalizations.of(context)!.reauthenticated,
  //               message: "Identity for '$_displayName' has been verified!",
  //               type: CustomNotificationType.success),
  //         );
  //     _logger.d("reauth with Google success!");
  //     _logger
  //         .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");

  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //           builder: (context) => EditProfilePage(
  //               displayName: _displayName,
  //               emailAddress: _emailAddress,
  //               profilePicURL: _profilePicURL)),
  //     );
  //   } on AuthException catch (e) {
  //     _errorMessage = e.toString();
  //     context.read<NotificationManager>().showNotification(
  //           context,
  //           NotificationData(
  //               title: AppLocalizations.of(context)!.failed,
  //               message: _errorMessage,
  //               type: CustomNotificationType.error),
  //         );
  //   }
  // }

  Future<void> handleReauthUser(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController,
      String routeToBePushed) async {
    _logger.d("user selected to reauth with native provider");
    try {
      AuthCredential credential = EmailAuthProvider.credential(
          email: emailController.text.trim(),
          password: passwordController.text);
      await _auth.reauthenticateUser(credential);

      refreshAttributes();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.reauthenticated,
                message: "Identity for '$_displayName' has been verified!",
                type: CustomNotificationType.success),
          );
      _logger.d("user: '$_displayName' reauth with native provider success!");
      _logger
          .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
      context.pushReplacementNamed(routeToBePushed);
    } on AuthException catch (e) {
      _errorMessage = e.toString();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.failed,
                message: _errorMessage,
                type: CustomNotificationType.error),
          );
    }
  }

  Future<void> handleChangePassword(
    BuildContext context,
    TextEditingController newPasswordController,
  ) async {
    _logger.d("user submitted a request to change password");
    try {
      await _auth.updateUserAccountPassword(newPasswordController.text);

      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.newChangeApplied,
                message: AppLocalizations.of(context)!.accPasswordIsUpdated,
                type: CustomNotificationType.success),
          );
      _logger.d("user account password is updated!");
      _logger
          .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
      context.goNamed('SettingsPage');
    } on AuthException catch (e) {
      _errorMessage = e.toString();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.failed,
                message: _errorMessage,
                type: CustomNotificationType.error),
          );
    }
  }

  Future<void> handleChangeEmail(
    BuildContext context,
    TextEditingController newEmailController,
  ) async {
    _logger.d("user submitted a request to change password");
    try {
      await _auth.updateUserAccountEmail(newEmailController.text);

      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.newChangeApplied,
                message: AppLocalizations.of(context)!.accEmailIsUpdated,
                type: CustomNotificationType.success),
          );
      _logger.d("user account email is updated!");
      _logger
          .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
      context.goNamed('SettingsPage');
    } on AuthException catch (e) {
      _errorMessage = e.toString();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.failed,
                message: _errorMessage,
                type: CustomNotificationType.error),
          );
    }
  }

  Future<void> handleSubmittedPasswordResetEmail(
    BuildContext context,
    TextEditingController emailController,
  ) async {
    _logger.d(
        "trying to send the password reset email to '${emailController.text.trim()}'");
    try {
      await _auth.resetPassword(emailController.text.trim());
      context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title:
                  AppLocalizations.of(context)!.passwordResentEmailHasBeenSent,
              message:
                  AppLocalizations.of(context)!.pleaseCheckoutEmailWeSentYou,
              type: CustomNotificationType.success));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EmailSentPage(email: emailController.text.trim())),
      );
    } on AuthException catch (e) {
      _errorMessage = e.toString();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.failed,
                message: _errorMessage,
                type: CustomNotificationType.error),
          );
    }
  }

  Future<void> handleChangeProfilePic(
    BuildContext context,
  ) async {
    _logger.d("user submitted a request to change the account profile pic");
    try {
      if (_auth.getCurrentUserAttributes()!['photoURL'] != '') {
        await _cloudObjectStorageWrapper.handleDeleteAllFilesInFolder(context,
            firebaseStoragePath: FirebaseStoragePaths.profile);
      }
      final uploadResult =
          await _cloudObjectStorageWrapper.handlePickAndUploadFile(context,
              firebaseStoragePath: FirebaseStoragePaths.profile);

      if (uploadResult != null) {
        final url = uploadResult[1];
        // ignore: unused_local_variable
        final path = uploadResult[0];
        await _auth.updateUserAccountProfilePic(url);
      }

      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.newChangeApplied,
                message: AppLocalizations.of(context)!.accProfilePicIsUpdated,
                type: CustomNotificationType.success),
          );
      _logger.d("user account profile picture is updated!");
      _logger
          .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
      context.goNamed('SettingsPage');
    } on AuthException catch (e) {
      _errorMessage = e.toString();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.failed,
                message: _errorMessage,
                type: CustomNotificationType.error),
          );
    }
  }

  Future<void> handleRemoveProfilePic(
    BuildContext context,
  ) async {
    _logger.d("user submitted a request to remove the account profile pic");
    try {
      if (_auth.getCurrentUserAttributes()!['photoURL'] != '') {
        await _cloudObjectStorageWrapper.handleDeleteAllFilesInFolder(context,
            firebaseStoragePath: FirebaseStoragePaths.profile);
      }
      await _auth.updateUserAccountProfilePic(null);

      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.newChangeApplied,
                message: AppLocalizations.of(context)!.accProfilePicIsUpdated,
                type: CustomNotificationType.success),
          );
      _logger.d("user account profile picture is removed!");
      _logger
          .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
      context.goNamed("SettingsPage");
    } on AuthException catch (e) {
      _errorMessage = e.toString();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.failed,
                message: _errorMessage,
                type: CustomNotificationType.error),
          );
    }
  }

  Future<void> handleUpdateUserAccountProfile(
      BuildContext context, String newDisplayName, PlatformFile? file) async {
    _logger.d("user submitted a request to update the account profile");
    try {
      if (_auth.getCurrentUserAttributes()!['photoURL'] != '') {
        await _cloudObjectStorageWrapper.handleDeleteAllFilesInFolder(context,
            firebaseStoragePath: FirebaseStoragePaths.profile,
            showNotification: false);
      }
      final uploadResult = await _cloudObjectStorageWrapper.handleUploadFile(
          context, file,
          firebaseStoragePath: FirebaseStoragePaths.profile,
          showNotification: false);

      String? url;
      if (uploadResult != null) {
        url = uploadResult[1];
        // ignore: unused_local_variable
        final path = uploadResult[0];
      }
      await _auth.updateUserAccountProfile(
          newDisplayName: newDisplayName, newProfilePicURL: url);

      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.newChangeApplied,
                message: AppLocalizations.of(context)!.accProfileIsUpdated,
                type: CustomNotificationType.success),
          );
      _logger.d("user account profile is updated!");
      _logger
          .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
      context.goNamed('SettingsPage');
    } on AuthException catch (e) {
      _errorMessage = e.toString();
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
                title: AppLocalizations.of(context)!.failed,
                message: _errorMessage,
                type: CustomNotificationType.error),
          );
    } finally {
      context.loaderOverlay.hide();
    }
  }

  /// Refreshes the current user, if signed in
  Future<void> handleRefreshUser() async {
    if (_auth.isUserLoggedIn()) {
      _logger.d("reloading user...");
      return await _auth.reloadUserAccount();
    }
    _logger.d("unable to reload user since no user is signed in");
  }
}
