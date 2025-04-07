/// lib/views/auth_views/full_screen_auth_redirection_page.dart
///
/// a page to redirect user
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class FullScreenRedirectionPage extends StatelessWidget {
  final String destinationRouteName;
  final String displayText;
  final String callToActionBtnText;
  const FullScreenRedirectionPage(
      {super.key,
      this.destinationRouteName = "AuthFlow",
      this.displayText =
          'The page you have requested requires you to be an authenticated user!',
      this.callToActionBtnText = 'Go login now!'});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            child: Padding(
      padding: UiConsts.PaddingAll_large,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          displayText,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        UiConsts.SizedBoxGapVertical_large,
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              padding: UiConsts.PaddingElevBtn,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => context.goNamed(destinationRouteName),
            child: Text(callToActionBtnText))
      ]),
    )));
  }
}
