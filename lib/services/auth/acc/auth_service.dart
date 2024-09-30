/// lib/services/auth/acc/auth_service.dart
///
/// the authentication service of the app with the help of Firebase Auth
///

// TODO: edit this auth service file

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:xiaokeai/errors/auth_exception/auth_exception.dart';
import 'package:xiaokeai/helpers/rate_limiter.dart';
import 'package:xiaokeai/shared/errors_code_and_msg/auth_errors.dart';
// import 'package:flutter/foundation.dart'
// show defaultTargetPlatform, kIsWeb, TargetPlatform;

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
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

      /// default error msg
      default:
        return e.message!;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    if (!_rateLimiter.canAttempt(email)) {
      throw AuthException(errorEnum: AuthErrors.AUTH_C07);
    }

    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _logger.e('Sign in failed: ${e.message}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during sign in: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password) async {
    if (!_rateLimiter.canAttempt(email)) {
      throw FirebaseAuthException(
        code: 'too-many-requests',
        message: 'Too many registration attempts. Please try again later.',
      );
    }

    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _logger.e('Registration failed: ${e.message}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during registration: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// sign user out from the system
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _logger.i("logout success");
    } on FirebaseAuthException catch (e) {
      _logger.e("Failed to logout: ${e.message}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e('Sign out failed: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// send a reset password email to user
  ///
  /// must call `completePasswordReset` after
  Future<void> resetPassword(String email) async {
    try {
      await _auth.setLanguageCode("th"); // set the locale to THAI
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i("reset password email has been sent to email: $email");
    } on FirebaseAuthException catch (e) {
      _logger.e('Password reset failed: ${e.message}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during password reset: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// complete password reset process
  ///
  /// must call after `resetPassword`
  Future<void> completePasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } on FirebaseAuthException catch (e) {
      _logger.e("Reset password failed: ${e.message}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during password reset: ${e.toString()}',
          error: e, stackTrace: StackTrace.current);
      rethrow;
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
      _logger.e("failed to delete user account: ${e.message}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e("failed to delete user account: ${e.toString()}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// update user account details: `DisplayName`
  Future<void> updateUserAccountDisplayName(String newDisplayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(newDisplayName);
    } on FirebaseAuthException catch (e) {
      _logger.e("failed to update user's display name: ${e.message}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e("failed to update user's display name: ${e.toString()}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// update user account details: `PhotoURL`
  Future<void> updateUserAccountProfilePic(String newProfilePicURL) async {
    try {
      await _auth.currentUser?.updatePhotoURL(newProfilePicURL);
    } on FirebaseAuthException catch (e) {
      _logger.e("failed to update user's profile pic: ${e.message}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e("failed to update user's profile pic: ${e.toString()}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// update user account's `password`
  Future<void> updateUserAccountPassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      _logger.e("failed to update user's account password: ${e.message}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e("failed to update user's account password: ${e.toString()}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// update user account's email
  ///
  /// must call `verifyUserNewEmail` before
  Future<void> updateUserAccountEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      _logger.e("failed to update user's account email: ${e.message}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e("failed to update user's account email: ${e.toString()}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// reauthenticate user
  Future<void> reauthenticateUser(AuthCredential credential) async {
    try {
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _logger.e("failed to reauthenticate user: ${e.message}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e("failed to reauthenticate user: ${e.toString()}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  // /// reauthenticate user with Google provider
  // Future<UserCredential?> reauthenticateUserWithGoogle() async {
  //   // if current platform is web
  //   if (kIsWeb) {
  //     try {
  //       GoogleAuthProvider googleProvider = GoogleAuthProvider();
  //       googleProvider
  //           .addScope('https://www.googleapis.com/auth/contacts.readonly');
  //       googleProvider.setCustomParameters({'login_hint': 'user@thaitune.io'});
  //       return await _auth.currentUser?.reauthenticateWithPopup(googleProvider);
  //     } on Exception catch (e) {
  //       _logger.e('Unexpected error during reauth with Google: ${e.toString()}',
  //           error: e, stackTrace: StackTrace.current);
  //       rethrow;
  //     }
  //   }
  //   // if current platform is mobile or other
  //   switch (defaultTargetPlatform) {
  //     case TargetPlatform.android || TargetPlatform.iOS:
  //       try {
  //         final googleUser = await GoogleSignIn().signIn();
  //         final googleAuth = await googleUser?.authentication;
  //         final credential = GoogleAuthProvider.credential(
  //             idToken: googleAuth?.idToken,
  //             accessToken: googleAuth?.accessToken);
  //         return await _auth.currentUser
  //             ?.reauthenticateWithCredential(credential);
  //       } on FirebaseAuthException catch (e) {
  //         _logger.e("Failed to reauth with Google: ${e.message}",
  //             error: e, stackTrace: StackTrace.current);
  //         rethrow;
  //       } catch (e) {
  //         _logger.e(
  //             "Unexpected error during reauth with Google: ${e.toString()}",
  //             error: e,
  //             stackTrace: StackTrace.current);
  //         rethrow;
  //       }
  //     default:
  //       throw UnsupportedError(
  //         'Sorry, we currently have no support for this platform: $defaultTargetPlatform',
  //       );
  //   }
  // }

  /// verify user's new account email
  Future<void> verifyUserNewEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      _logger.e("failed to verify user's account new email: ${e.message}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    } catch (e) {
      _logger.e("failed to verify user's account new email: ${e.toString()}",
          error: e, stackTrace: StackTrace.current);
      rethrow;
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
