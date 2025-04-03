/// lib/services/auth/acc/auth_service.dart
///
/// the authentication service of the app with the help of Firebase Auth
///

// TODO: edit this auth service file

import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:xiaokeai/errors/auth_exception/auth_exception.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';
import 'package:xiaokeai/helpers/rate_limiter.dart';
import 'package:xiaokeai/shared/errors_code_and_msg/auth_errors.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = locator<Logger>();
  final RateLimiter _rateLimiter = RateLimiter();

  FirebaseAuth? get authInstance => _auth;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  static String getReadableFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      /// below are shared cases
      case 'invalid-email':
        return 'The provided email address is not valid.';
      case "operation-not-allowed":
        return "The requested operation is not allowed";
      case 'weak-password':
        return 'The password provided is too weak.';
      case "user-disabled":
        return "This account is currently disabled, please contact our support.";
      case 'email-already-in-use':
        return 'There is already an account exists with this email.';
      case "invalid-credential":
        return "Given credential is incorrect, malformed or has expired.";

      /// below are sign in related
      case 'user-not-found':
        return 'No user found with provided credentials';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case "invalid-verification-code":
        return "the verification code of the credential is not valid.";

      /// below are forgot password related
      case "auth/invalid-email":
        return "The provided email address is not valid.";
      case "auth/missing-android-pkg-name":
        return "An Android package name must be provided if the Android app is required to be installed.";
      case "auth/missing-continue-uri":
        return "A continue URL must be provided in the request.";
      case "auth/missing-ios-bundle-id":
        return "An iOS Bundle ID must be provided if an App Store ID is provided.";
      case "auth/invalid-continue-uri":
        return "The continue URL provided in the request is invalid.";
      case "auth/unauthorized-continue-uri":
        return "The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.";
      case "auth/user-not-found":
        return "No user account found that is associated with the provided email address";
      case "expired-action-code":
        return "Given code has expired.";
      case "invalid-action-code":
        return "Given code is invalid, likely the code is malformed or has already been used";

      /// others
      case "requires-recent-login":
        // TODO: make sure to handle the redirection and identity verification
        return "You are required to verify your identity before process.";
      case "user-token-expired" || "auth/user-token-expired":
        return "Login credential is no longer valid, please logout & sign in again.";

      /// default error msg
      default:
        return e.message!;
    }
  }

  void _mapFirebaseErrorsAndThrowsError(
      FirebaseAuthException e, String process) {
    switch (e.code) {
      /// below are shared cases
      case 'invalid-email':
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C01,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "operation-not-allowed":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S01,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case 'weak-password':
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C02,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "user-disabled":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S02,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case 'email-already-in-use':
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C03,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "invalid-credential":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C04,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");

      /// below are sign in related
      case 'user-not-found':
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C05,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case 'wrong-password':
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C06,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case 'too-many-requests':
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C07,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "invalid-verification-code":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C08,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");

      /// below are forgot password related
      case "auth/invalid-email":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C01,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "auth/missing-android-pkg-name":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S03,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "auth/missing-continue-uri":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S04,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "auth/missing-ios-bundle-id":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S05,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "auth/invalid-continue-uri":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S06,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "auth/unauthorized-continue-uri":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S07,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "auth/user-not-found":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C10,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "expired-action-code":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S08,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "invalid-action-code":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S09,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");

      /// others
      case "requires-recent-login":
        // TODO: make sure to handle the redirection and identity verification
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C11,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
      case "user-token-expired" || "auth/user-token-expired":
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_C12,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");

      /// default error
      default:
        throw AuthException(
            process: process,
            errorEnum: AuthErrors.AUTH_S00,
            error: e,
            errorDetailsFromDependency: "${e.code}...${e.message!}");
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    if (!_rateLimiter.canAttempt(email)) {
      throw AuthException(errorEnum: AuthErrors.AUTH_C07, process: 'login');
    }
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, 'login');
    } catch (e) {
      throw AuthException(
          process: "login",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
    return null;
  }

  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password) async {
    if (!_rateLimiter.canAttempt(email)) {
      throw AuthException(errorEnum: AuthErrors.AUTH_C07, process: 'register');
    }

    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, 'register');
    } catch (e) {
      throw AuthException(
          process: "register",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
    return null;
  }

  /// sign user out from the system
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _logger.i("logout success");
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, 'signout');
    } catch (e) {
      throw AuthException(
          process: "signout",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// set the Firebase Auth locale to the given language code
  ///
  /// When set to null, sets the user-facing language code to be the default app language.
  Future<void> setAuthLocale(String? languageCode) async {
    await _auth.setLanguageCode(languageCode);
    _logger.d("Auth language is now '${languageCode ?? _auth.languageCode}'");
    notifyListeners();
  }

  /// send a reset password email to user
  ///
  /// must call `completePasswordReset` after
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.d("reset password email has been sent to email: '$email'");
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, 'reset user account password');
    } catch (e) {
      throw AuthException(
          process: "reset user account password",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// complete password reset process
  ///
  /// must call after `resetPassword`
  Future<void> completePasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, 'reset user account password');
    } catch (e) {
      throw AuthException(
          process: "reset user account password",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// sign user out and delete the account
  /// make sure to handle the redirection and identity verification
  ///
  /// TODO: make sure to handle the redirection and identity verification
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, 'delete user account');
    } catch (e) {
      throw AuthException(
          process: "delete user account",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// update user account profile: `DisplayName` & `PhotoURL`
  Future<void> updateUserAccountProfile(
      {required String newDisplayName,
      required String? newProfilePicURL}) async {
    try {
      await _auth.currentUser?.updateProfile(
          displayName: newDisplayName, photoURL: newProfilePicURL);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, "update user's profile");
    } catch (e) {
      throw AuthException(
          process: "update user's profile",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// update user account details: `DisplayName`
  Future<void> updateUserAccountDisplayName(String newDisplayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(newDisplayName);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, "update user's display name");
    } catch (e) {
      throw AuthException(
          process: "update user's display name",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// update user account details: `PhotoURL`
  Future<void> updateUserAccountProfilePic(String? newProfilePicURL) async {
    try {
      await _auth.currentUser?.updatePhotoURL(newProfilePicURL);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, "update user's profile pic");
    } catch (e) {
      throw AuthException(
          process: "update user's profile pic",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// update user account's `password`
  Future<void> updateUserAccountPassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, "update user's account password");
    } catch (e) {
      throw AuthException(
          process: "update user's account password",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// update user account's email
  ///
  /// must call `verifyUserNewEmail` before
  Future<void> updateUserAccountEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, "update user's account email");
    } catch (e) {
      throw AuthException(
          process: "update user's account email",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// reauthenticate user
  Future<void> reauthenticateUser(AuthCredential credential) async {
    try {
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, "reauthenticate user");
    } catch (e) {
      throw AuthException(
          process: "reauthenticate user",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// verify user's new account email
  Future<void> verifyUserNewEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      _mapFirebaseErrorsAndThrowsError(e, "verify user's account new email");
    } catch (e) {
      throw AuthException(
          process: "verify user's account new email",
          errorEnum: AuthErrors.AUTH_U00,
          st: StackTrace.current,
          errorDetailsFromDependency: e.toString(),
          error: e);
    }
  }

  /// determine the current user is logged in or not
  ///
  /// returns `false` if current user is currently not logged in
  ///
  /// otherwise returns `true`
  bool isUserLoggedIn() {
    if (_auth.currentUser == null) {
      return false;
    } else {
      return true;
    }
  }

  /// Refreshes the current user, if signed in
  Future<void> reloadUserAccount() async {
    if (isUserLoggedIn()) {
      _logger.d("reloading user...");
      return await _auth.currentUser?.reload();
    }
    _logger.d("unable to reload user since no user is signed in");
  }

  /// Retreives all available user attributes from Firebase
  Map<String, dynamic>? getCurrentUserAttributes() {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        Map<String, dynamic> mapperOfCurrentUserAttributes = {
          "displayName": currentUser.displayName,
          "uid": currentUser.uid,
          "emailVerified": currentUser.emailVerified,
          "isAnonymous": currentUser.isAnonymous,
          "metadata": currentUser.metadata,
          "providerData": currentUser.providerData,
          "email": currentUser.email,
          "phoneNumber": currentUser.phoneNumber,
          "photoURL": currentUser.photoURL,
          "refreshToken": currentUser.refreshToken,
          "tenantId": currentUser.tenantId
        };
        return Map.from(mapperOfCurrentUserAttributes);
      }
      return null;
    } catch (e) {
      _logger.e('Unable to get current user attributes: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
    }
    return null;
  }
}
