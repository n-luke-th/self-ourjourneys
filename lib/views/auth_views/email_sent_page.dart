/// lib/views/auth_views/email_sent_page.dart
///
///
/// this is the confirmation page that the email is now sent to the given address

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/quick_settings_menu.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class EmailSentPage extends StatelessWidget {
  final String email;
  const EmailSentPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: "Email Sent",
      appBarBackgroundColor: Colors.transparent,
      appbarActions: [QuickSettingsMenu()],
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            end: Alignment.topCenter,
            begin: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
              Theme.of(context).colorScheme.tertiaryContainer
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxWidth: 550),
              margin: UiConsts.PaddingAll_large,
              transformAlignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: UiConsts.PaddingAll_large,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 110,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    UiConsts.SizedBoxGapVertical_large,
                    Text(
                      "Please checkout mailbox of '$email'",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    UiConsts.SizedBoxGapVertical_large,
                    UiConsts.SizedBoxGapVertical_large,
                    ElevatedButton(
                      onPressed: () => context.goNamed("LoginPage"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                        backgroundColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                        padding: UiConsts.PaddingElevBtn,
                        shape: RoundedRectangleBorder(
                          borderRadius: UiConsts.BorderRadiusCircular_standard,
                        ),
                      ),
                      child: Text("Go LOGIN now"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
