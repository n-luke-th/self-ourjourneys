/// lib/views/auth_views/change_password_page.dart
///
/// change password page
/// TODO: edit this page
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:xiaokeai/components/main_view.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/services/auth/acc/auth_wrapper.dart';
import 'package:xiaokeai/services/pref/shared_pref_service.dart';
import 'package:xiaokeai/shared/views/ui_consts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPage();
}

class _ChangePasswordPage extends State<ChangePasswordPage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final SharedPreferencesService _prefs = getIt<SharedPreferencesService>();
  final _formKey = GlobalKey<FormState>();
  final _passwordFieldKey = GlobalKey<FormFieldState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  late Color fillColorPassword1;
  late Color fillColorPassword2;
  late Color labelTextColorPassword1;
  late Color labelTextColorPassword2;

  @override
  void initState() {
    super.initState();
    fillColorPassword1 = Colors.transparent;
    fillColorPassword2 = Colors.transparent;
    labelTextColorPassword1 = ThemeMode
                .values[_prefs.getInt('themeMode') ?? ThemeMode.system.index] ==
            ThemeMode.dark
        ? Colors.white
        : Colors.black;
    labelTextColorPassword2 = ThemeMode
                .values[_prefs.getInt('themeMode') ?? ThemeMode.system.index] ==
            ThemeMode.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarBackgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBarTitle: AppLocalizations.of(context)!.login.toUpperCase(),
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
                      UiConsts.SizedBoxGapVertical_large,
                      TextFormField(
                          key: _passwordFieldKey,
                          controller: _passwordController,
                          obscureText: !_passwordVisible1,
                          // autofocus: false,
                          validator: FormBuilderValidators.password(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            setState(() {
                              if (_passwordFieldKey.currentState?.validate() ==
                                  true) {
                                fillColorPassword1 = Colors.transparent;
                                labelTextColorPassword1 =
                                    Theme.of(context).colorScheme.onSurface;
                              } else {
                                fillColorPassword1 =
                                    Theme.of(context).cardColor;
                                labelTextColorPassword1 =
                                    Theme.of(context).colorScheme.onSurface;
                              }
                            });
                          },
                          cursorColor: labelTextColorPassword1,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible1
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).hintColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible1 = !_passwordVisible1;
                                  });
                                },
                              ),
                              hintText: AppLocalizations.of(context)!.password,
                              labelText: AppLocalizations.of(context)!.password,
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                              fillColor: fillColorPassword1,
                              hoverColor: fillColorPassword1,
                              floatingLabelStyle:
                                  TextStyle(color: labelTextColorPassword1),
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
                          key: _confirmPasswordFieldKey,
                          controller: _confirmPasswordController,
                          obscureText: !_passwordVisible2,
                          // autofocus: false,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              // TODO: localize this
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            setState(() {
                              if (_confirmPasswordFieldKey.currentState
                                      ?.validate() ==
                                  true) {
                                fillColorPassword2 = Colors.transparent;
                                labelTextColorPassword2 =
                                    Theme.of(context).colorScheme.onSurface;
                              } else {
                                fillColorPassword2 =
                                    Theme.of(context).cardColor;
                                labelTextColorPassword2 =
                                    Theme.of(context).colorScheme.onSurface;
                              }
                            });
                          },
                          cursorColor: labelTextColorPassword2,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible2
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).hintColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible2 = !_passwordVisible2;
                                  });
                                },
                              ),
                              hintText:
                                  AppLocalizations.of(context)!.confirmPassword,
                              labelText:
                                  AppLocalizations.of(context)!.confirmPassword,
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                              filled: true,
                              fillColor: fillColorPassword2,
                              hoverColor: fillColorPassword2,
                              floatingLabelStyle:
                                  TextStyle(color: labelTextColorPassword2),
                              // labelStyle:
                              //     TextStyle(color: labelTextColorPassword2),
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
                      UiConsts.SizedBoxGapVertical_large,
                      ElevatedButton(
                        onPressed: () async => await _changePassword(),
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
                        child: Text(
                            AppLocalizations.of(context)!.login.toUpperCase()),
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

  Future<void> _changePassword() async {
    try {
      context.loaderOverlay.show();
      if (_formKey.currentState!.validate()) {
        await _authWrapper.handleChangePassword(context, _passwordController);
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    } finally {
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
    }
  }
}
