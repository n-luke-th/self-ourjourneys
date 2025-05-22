/// lib/services/auth/acc/auth_wrapper.dart
/// the authentication wrapper functions
/// are the top-level functions that will perform
/// neccessary auth actions called when user trigger call to action btn (login btn, send password reset email, etc.)

// ignore_for_file: use_build_context_synchronously
// TODO: edit this auth wrapper
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:ourjourneys/errors/auth_exception/auth_exception.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/services/notifications/notification_manager.dart';
import 'package:ourjourneys/services/notifications/notification_service.dart';
import 'package:ourjourneys/services/pref/shared_pref_service.dart'
    show SharedPreferencesService;
import 'package:ourjourneys/shared/errors_code_and_msg/auth_errors.dart'
    show AuthErrors;

class AuthWrapper {
  final Logger _logger = getIt<Logger>();
  final AuthService _auth = getIt<AuthService>();
  final SharedPreferencesService _sharedPreferencesService =
      getIt<SharedPreferencesService>();
  String _uid = "";
  String? _idToken;
  String _errorMessage = "";
  String _displayName = "_OurJourneys user_";
  String _emailAddress = "_OurJourneys user_";
  String _profilePicURL = "_OurJourneys user_";

  String get uid => _uid;
  String? get idToken => _idToken;
  String get displayName => _displayName;
  String get emailAddress => _emailAddress;
  String get profilePicURL => _profilePicURL;

  AuthWrapper();

  /// refresh all attributes of the user
  void refreshAttributes() {
    if (_auth.isUserLoggedIn()) {
      _uid = _auth.getCurrentUserAttributes()!['uid'];
      _emailAddress = _auth.getCurrentUserAttributes()!['email'].toString();
      _displayName = _auth.getCurrentUserAttributes()!['displayName'] == null
          ? _auth.getCurrentUserAttributes()!['email'].toString()
          : _auth.getCurrentUserAttributes()!['displayName'].toString();
      _profilePicURL = _auth.getCurrentUserAttributes()!['photoURL'] ??
          "https://ui-avatars.com/api/?background=F2BE22&color=fff&name=$_emailAddress";
    } else {
      _uid = "";
      _emailAddress = "Our Journeys user";
      _displayName = "_Unauthenticated user_";
      _profilePicURL =
          "https://ui-avatars.com/api/?background=F2BE22&color=fff&name=$_emailAddress";
    }
  }

  /// refresh the uid of the user
  void refreshUid() {
    if (_auth.isUserLoggedIn()) {
      _uid = _auth.getCurrentUserAttributes()!['uid'];
    } else {
      _uid = "";
    }
  }

  Future<void> refreshIdToken({bool forceNewToken = false}) async {
    if (_auth.isUserLoggedIn()) {
      _logger.d("refreshing id token...");
      _idToken = await _auth.currentUser?.getIdToken(forceNewToken);
    }
  }

  /// determine the current user is logged in or not
  ///
  /// returns `false` if current user is currently not logged in
  /// otherwise returns `true`
  ///
  /// wrapper of the method of [AuthService]
  bool isUserLoggedIn() {
    return _auth.isUserLoggedIn();
  }

  /// Retreives all available user attributes from Firebase
  ///
  /// wrapper of the method of [AuthService]
  Map<String, dynamic>? getCurrentUserAttributes() {
    try {
      return _auth.getCurrentUserAttributes();
    } catch (e) {
      _logger.e('Unable to get current user attributes: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
    }
    return null;
  }

  Future<void> handleLogout(
    BuildContext context, {
    String confirmationTitle = "Logout?",
    String confirmationMessage = "Are you sure you want to logout?",
    String confirmationCancelText = "Cancel",
    String confirmationConfirmText = "Logout",
    bool showConfirmationDialog = true,
  }) async {
    if (showConfirmationDialog) {
      final bool? confirmed = await DialogService.showConfirmationDialog(
          context: context,
          title: confirmationTitle,
          message: confirmationMessage,
          cancelText: confirmationCancelText,
          confirmText: confirmationConfirmText);
      if (confirmed == true) {
        _logger.d("user confirmed logout");
        await _logout(context);
      }
    } else {
      await _logout(context);
    }
  }

  Future<void> _logout(BuildContext context) async {
    context.loaderOverlay.show();
    // delete prefs data
    _logger.d("deleting user prefs data...");
    await _clearUserPref();
    _logger.d("user prefs data deleted");
    // end deleting prefs data
    await _auth.signOut();
    context.loaderOverlay.hide();
  }

  Future<void> handleSignIn(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.i("user selected to login with app provider");
    try {
      await _auth.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );
      refreshAttributes();
      if (!suppressNotification) {
        context.read<NotificationManager>().showNotification(
              context,
              overrideNotiData ??
                  NotificationData(
                      title: 'Login Success!',
                      message: "Welcome, $_displayName",
                      type: CustomNotificationType.success),
            );
      }
      _logger.i("user: '$_displayName' login success!");
      _logger.d(
          "user attributes: ${_auth.getCurrentUserAttributes()!['providerData'].toString()}");
    } on AuthException catch (e) {
      if (!suppressNotification) {
        _errorMessage = e.toString();
        context.read<NotificationManager>().showNotification(
              context,
              overrideErrorNotiData ??
                  NotificationData(
                      title: 'Oops!',
                      message: _errorMessage,
                      type: CustomNotificationType.error),
            );
      }
      rethrow;
    } catch (e) {
      if (!suppressNotification) {
        _errorMessage = e.toString();
        context.read<NotificationManager>().showNotification(
              context,
              overrideErrorNotiData ??
                  NotificationData(
                      title: 'Oops!',
                      message: _errorMessage,
                      type: CustomNotificationType.error),
            );
      }
      rethrow;
    } finally {
      context.loaderOverlay.hide();
    }
  }

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
                title: "Reauthentication",
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
                title: "Oops!",
                message: _errorMessage,
                type: CustomNotificationType.error),
          );
    }
  }

  Future<void> handleChangePassword(
      BuildContext context, TextEditingController newPasswordController,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.i("user submitted a request to change password");
    try {
      await _auth.updateUserAccountPassword(newPasswordController.text);

      if (!suppressNotification) {
        context.read<NotificationManager>().showNotification(
              context,
              overrideNotiData ??
                  NotificationData(
                      title: 'Change password',
                      message: "Password is updated!",
                      type: CustomNotificationType.success),
            );
      }
      _logger.i("user account password is updated!");
      _logger
          .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
      // context.goNamed('Settings');
    } on FirebaseAuthException catch (e) {
      _handleRequiresRecentLogin(context, e, toPasswordPage: true);
      if (!suppressNotification) {
        _errorMessage = AuthService.getReadableErrorMessage(e);
        context.read<NotificationManager>().showNotification(
              context,
              overrideErrorNotiData ??
                  NotificationData(
                      title: 'Oops!',
                      message: _errorMessage,
                      type: CustomNotificationType.error),
            );
      }
      rethrow;
    } catch (e) {
      if (!suppressNotification) {
        _errorMessage = e.toString();
        context.read<NotificationManager>().showNotification(
              context,
              overrideErrorNotiData ??
                  NotificationData(
                      title: 'Oops!',
                      message: _errorMessage,
                      type: CustomNotificationType.error),
            );
      }
      rethrow;
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> handleSubmittedPasswordResetEmail(
      BuildContext context, TextEditingController emailController,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.i(
        "trying to send the password reset email to ${emailController.text.trim()}");
    try {
      await _auth.resetPassword(emailController.text.trim());
      if (!suppressNotification) {
        context.read<NotificationManager>().showNotification(
            context,
            overrideNotiData ??
                NotificationData(
                    title: "Change password",
                    message: "Password reset email sent!",
                    type: CustomNotificationType.info));
      }
      context.pushReplacementNamed("LoginPage");
    } on FirebaseAuthException catch (e) {
      _auth.mapFirebaseErrorsAndThrowsError(e, "reset password");
      rethrow;
    } catch (e) {
      throw AuthException(
        process: "reset password",
        errorEnum: AuthErrors.AUTH_S00,
        error: e,
      );
    } finally {
      context.loaderOverlay.hide();
    }
  }

  /// returns `true` if the user email is valid
  bool _verifyUserEmail(
      BuildContext context, TextEditingController newEmailController,
      {bool suppressNotification = false,
      NotificationData? overrideErrorNotiData}) {
    _logger.i("user have to verify their new email before change the email");
    if (newEmailController.text.trim().isEmpty) {
      context.loaderOverlay.hide();
      _logger.i("user did not enter their new email");
      if (!suppressNotification) {
        context.read<NotificationManager>().showNotification(
              context,
              overrideErrorNotiData ??
                  NotificationData(
                      title: 'Change Email',
                      message: "Enter your new email",
                      type: CustomNotificationType.info),
            );
      }
      throw Exception("user did not enter their new email");
    } else if (newEmailController.text.toLowerCase().trim() ==
        _emailAddress.toLowerCase()) {
      context.loaderOverlay.hide();
      _logger.i("user enter the same email as their current email");
      if (!suppressNotification) {
        context.read<NotificationManager>().showNotification(
              context,
              overrideErrorNotiData ??
                  NotificationData(
                      title: 'Change Email',
                      message: "Email already in use",
                      type: CustomNotificationType.error),
            );
      }
      throw Exception("user enter the same email as their current email");
    }
    _logger.d("user enter a valid new email");
    context.loaderOverlay.hide();
    return true;
  }

  Future<void> handleUpdateUserEmail(
      BuildContext context, TextEditingController emailController,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.i("user selected to update the email");
    bool hasError = false;
    bool isVerifyEmailSent = false;
    try {
      // Verify email
      isVerifyEmailSent = _verifyUserEmail(context, emailController,
          suppressNotification: suppressNotification);
    } catch (e) {
      hasError = true;
      _logger.e("Error verifying email: ${e.toString()}");
      rethrow;
    }
    if (!hasError && isVerifyEmailSent) {
      try {
        await _auth.updateUserAccountEmail(emailController.text.trim());

        // Log successful update

        _logger.d("verify email sent!");
        _logger.i(
            "Successfully pending to update the email to: ${emailController.text.trim()}");
        _logger
            .d("Updated user attributes: ${_auth.getCurrentUserAttributes()}");

        if (!suppressNotification) {
          context.read<NotificationManager>().showNotification(
                context,
                overrideNotiData ??
                    NotificationData(
                        title: 'Success',
                        message: "Email updated successfully",
                        type: CustomNotificationType.success),
              );
        }
        Future.delayed(Durations.short1);
        context.pushReplacementNamed("SentVerifyEmail",
            pathParameters: {"email": emailController.text.trim()});
      } on FirebaseAuthException catch (e) {
        _handleRequiresRecentLogin(context, e);
        if (!suppressNotification && e.code != 'requires-recent-login') {
          _errorMessage = AuthService.getReadableErrorMessage(e);
          context.read<NotificationManager>().showNotification(
                context,
                overrideErrorNotiData ??
                    NotificationData(
                        title: 'Oops!',
                        message: _errorMessage,
                        type: CustomNotificationType.error),
              );
        }
        rethrow;
      } catch (e) {
        if (!suppressNotification) {
          _errorMessage = e.toString();
          context.read<NotificationManager>().showNotification(
              context,
              overrideErrorNotiData ??
                  NotificationData(
                      title: 'Oops!',
                      message: _errorMessage,
                      type: CustomNotificationType.error));
        }
        rethrow;
      }
    }
  }

  Future<void> handleUpdateDisplayName(
      BuildContext context, TextEditingController displayNameController,
      {bool suppressNotification = false,
      NotificationData? overrideNotiData,
      NotificationData? overrideErrorNotiData}) async {
    _logger.d("user selected to update the display name");
    try {
      context.loaderOverlay.show();
      await _auth.updateUserAccountDisplayName(displayNameController.text);

      context.read<NotificationManager>().showNotification(
            context,
            overrideNotiData ??
                NotificationData(
                    title: 'Change Successful',
                    message: "Changed to '${displayNameController.text}'",
                    type: CustomNotificationType.success),
          );
      _logger.d("user's display name updated");
      _logger
          .d("user attributes: ${_auth.getCurrentUserAttributes().toString()}");
    } on FirebaseAuthException catch (e) {
      if (!suppressNotification) {
        _errorMessage = AuthService.getReadableErrorMessage(e);
        context.read<NotificationManager>().showNotification(
              context,
              overrideErrorNotiData ??
                  NotificationData(
                      title: 'Oops!',
                      message: _errorMessage,
                      type: CustomNotificationType.error),
            );
      }
      rethrow;
    } catch (e) {
      if (!suppressNotification) {
        _errorMessage = e.toString();
        context.read<NotificationManager>().showNotification(
              context,
              overrideErrorNotiData ??
                  NotificationData(
                      title: 'Oops!',
                      message: _errorMessage,
                      type: CustomNotificationType.error),
            );
      }
      rethrow;
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

  Future<bool> _clearUserPref() async {
    return await _sharedPreferencesService.clearAll();
  }

  void _handleRequiresRecentLogin(BuildContext context, FirebaseAuthException e,
      {bool toPasswordPage = false}) {
    if (e.code == 'requires-recent-login') {
      _logger.d("user is not recently signed in, authenticating again...");
      if (toPasswordPage) {
        context.push("/settings/reauth:ChangePassword");
      } else {
        context.push("/settings/reauth:EditProfile");
      }

      return;
    }
  }
}
