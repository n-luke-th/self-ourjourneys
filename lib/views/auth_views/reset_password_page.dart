/// lib/views/auth_views/reset_password_page.dart
///
/// reset password page
/// TODO: edit this page
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:xiaokeai/components/main_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xiaokeai/shared/views/ui_consts.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: AppLocalizations.of(context)!.resetPassword.toUpperCase(),
      appBarBackgroundColor: Colors.transparent,
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
                      SizedBox(height: 30),
                      Text(
                        'Enter your email to reset your password',
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
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                UiConsts.BorderRadiusCircular_standard,
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!
                            .resetPassword
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

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      // Implement Firebase password reset logic here
      FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: _emailController.text,
      )
          .then((_) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent')),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send password reset email')),
        );
      });
    }
  }
}
