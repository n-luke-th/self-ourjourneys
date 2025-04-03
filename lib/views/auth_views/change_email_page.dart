/// lib/views/auth_views/reset_password_page.dart
///
/// change email page
/// TODO: edit this page
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:xiaokeai/components/main_view.dart';
import 'package:xiaokeai/components/quick_settings_menu.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/l10n/generated/i18n/app_localizations.dart'
    show AppLocalizations;
import 'package:xiaokeai/services/auth/acc/auth_wrapper.dart';
import 'package:xiaokeai/shared/views/ui_consts.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: AppLocalizations.of(context)!.changeEmail.toUpperCase(),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 110,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      UiConsts.SizedBoxGapVertical_large,
                      Text(
                        AppLocalizations.of(context)!.askForUserEmail,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      UiConsts.SizedBoxGapVertical_large,
                      TextFormField(
                          controller: _emailController,
                          autofocus: false,
                          validator: FormBuilderValidators.email(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email_rounded),
                              hintText: AppLocalizations.of(context)!.email,
                              labelText: AppLocalizations.of(context)!.email,
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                              floatingLabelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              errorStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface),
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
                                borderSide: BorderSide(
                                    color: Theme.of(context).focusColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    UiConsts.BorderRadiusCircular_standard,
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                              border: InputBorder.none)),
                      UiConsts.SizedBoxGapVertical_large,
                      ElevatedButton(
                        onPressed: () async => _changeEmail(),
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          padding: UiConsts.PaddingElevBtn,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                UiConsts.BorderRadiusCircular_standard,
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!
                            .changeEmail
                            .toUpperCase()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changeEmail() async {
    try {
      context.loaderOverlay.show();
      if (_formKey.currentState!.validate()) {
        await _authWrapper.handleChangeEmail(context, _emailController);
      }
    } finally {
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
    }
  }
}
