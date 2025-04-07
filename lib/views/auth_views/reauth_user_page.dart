/// lib/views/auth_views/reauth_user_page.dart
///
/// reauthenticate user page

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/quick_settings_menu.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/pref/shared_pref_service.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class ReauthUserPage extends StatefulWidget {
  final String routeToBePushed;
  const ReauthUserPage({super.key, required this.routeToBePushed});

  @override
  State<ReauthUserPage> createState() => _ReauthUserPage();
}

class _ReauthUserPage extends State<ReauthUserPage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final SharedPreferencesService _prefs = getIt<SharedPreferencesService>();
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  late Color fillColorEmail;
  late Color fillColorPassword;
  late Color labelTextColorEmail;
  late Color labelTextColorPassword;

  @override
  void initState() {
    super.initState();
    fillColorEmail = Colors.transparent;
    fillColorPassword = Colors.transparent;
    labelTextColorEmail = ThemeMode
                .values[_prefs.getInt('themeMode') ?? ThemeMode.system.index] ==
            ThemeMode.dark
        ? Colors.white
        : Colors.black;
    labelTextColorPassword = ThemeMode
                .values[_prefs.getInt('themeMode') ?? ThemeMode.system.index] ==
            ThemeMode.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarBackgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBarTitle: "Reauthenticate",
      appbarActions: [QuickSettingsMenu()],
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
                        Icons.favorite_outline_rounded,
                        size: 110,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      UiConsts.spaceForTextAndElement,
                      Text(
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                          "You need to reauthenticate: ${widget.routeToBePushed.contains('Email') == true ? 'Change email' : 'Chage password'}"),
                      UiConsts.SizedBoxGapVertical_large,
                      TextFormField(
                          key: _emailKey,
                          controller: _emailController,
                          // autofocus: false,
                          validator: FormBuilderValidators.email(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            setState(() {
                              if (_emailKey.currentState?.validate() == true) {
                                fillColorEmail = Colors.transparent;
                                labelTextColorEmail =
                                    Theme.of(context).colorScheme.onSurface;
                              } else {
                                fillColorEmail = Theme.of(context).cardColor;
                                labelTextColorEmail =
                                    Theme.of(context).colorScheme.onSurface;
                              }
                            });
                          },
                          cursorColor: labelTextColorEmail,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email_rounded),
                              hintText: "email",
                              labelText: "email",
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                              fillColor: fillColorEmail,
                              hoverColor: fillColorEmail,
                              floatingLabelStyle:
                                  TextStyle(color: labelTextColorEmail),
                              // labelStyle: TextStyle(color: labelTextColorEmail),
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
                      TextFormField(
                          key: _passwordKey,
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          // autofocus: false,
                          validator: FormBuilderValidators.required(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            setState(() {
                              if (_passwordKey.currentState?.validate() ==
                                  true) {
                                fillColorPassword = Colors.transparent;
                                labelTextColorPassword =
                                    Theme.of(context).colorScheme.onSurface;
                              } else {
                                fillColorPassword = Theme.of(context).cardColor;
                                labelTextColorPassword =
                                    Theme.of(context).colorScheme.onSurface;
                              }
                            });
                          },
                          cursorColor: labelTextColorPassword,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).hintColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              hintText: "password",
                              labelText: "password",
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                              filled: true,
                              fillColor: fillColorPassword,
                              hoverColor: fillColorPassword,
                              floatingLabelStyle:
                                  TextStyle(color: labelTextColorPassword),
                              // labelStyle:
                              //     TextStyle(color: labelTextColorPassword),
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
                      UiConsts.SizedBoxGapVertical_standard,
                      ElevatedButton(
                        onPressed: () async => _reauth(widget.routeToBePushed),
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          padding: UiConsts.PaddingAll_large,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                UiConsts.BorderRadiusCircular_standard,
                          ),
                        ),
                        child: Text("reauthenticate".toUpperCase()),
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

  Future<void> _reauth(String routeToBePushed) async {
    try {
      context.loaderOverlay.show();
      if (_formKey.currentState!.validate()) {
        await _authWrapper.handleReauthUser(
            context, _emailController, _passwordController, routeToBePushed);
        _passwordController.clear();
      }
    } finally {
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
    }
  }
}
