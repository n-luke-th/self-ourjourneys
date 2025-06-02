/// lib/views/auth_views/protected_auth_view_wrapper.dart
///
/// A helper widget to help protect any page that required
/// wrap this widget to any widget that want to be protected to any unauthenticated users

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/views/auth_views/full_screen_auth_redirection_page.dart';

class ProtectedAuthViewWrapper extends StatelessWidget {
  final Widget child;
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final Logger _logger = getIt<Logger>();

  ProtectedAuthViewWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (_authWrapper.isUserLoggedIn()) {
      return child;
    } else {
      _logger.d(
          "current user is not authenticated!\nsuggested to redirect to login page");
      return FullScreenRedirectionPage(
        callToActionBtnText: "Go login now!".toUpperCase(),
        displayText: "You must be authenticated to access this page!",
      );
    }
  }
}
