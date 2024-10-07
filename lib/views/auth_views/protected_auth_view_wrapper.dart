/// lib/views/auth_views/protected_auth_view_wrapper.dart
///
/// A helper widget to help protect any page that required
/// wrap this widget to any widget that want to be protected to any unauthenticated users

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/services/auth/acc/auth_service.dart';
import 'package:xiaokeai/views/auth_views/full_screen_auth_redirection_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProtectedAuthViewWrapper extends StatelessWidget {
  final Widget child;
  final _auth = getIt<AuthService>();
  final Logger _logger = Logger();

  ProtectedAuthViewWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (_auth.isUserLoggedIn()) {
      _logger.d("current user is authenticated!");
      return child;
    } else {
      _logger.d(
          "current user is not authenticated!\nsuggested to redirect to login page");
      return FullScreenRedirectionPage(
        callToActionBtnText: AppLocalizations.of(context)!.goLoginNow,
        displayText:
            AppLocalizations.of(context)!.requestedPageMustBeAuthenticatedUser,
      );
    }
  }
}
