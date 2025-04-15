/// lib/views/auth_views/auth_flow.dart
///
/// auth flow of the app

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart';

import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/views/auth_views/login_page.dart';

class AuthFlow extends StatelessWidget {
  AuthFlow({super.key});
  final AuthService _auth = getIt<AuthService>();
  final Logger _logger = getIt<Logger>();

  @override
  Widget build(BuildContext context) {
    context.loaderOverlay.show();
    return StreamBuilder<User?>(
        stream: _auth.authStateChanges,
        builder: (context, snapshot) {
          context.loaderOverlay.show();
          if (snapshot.hasError) {
            context.loaderOverlay.hide();
            _logger.e("Authentication inilization error: ${snapshot.error}",
                error: snapshot.error, stackTrace: StackTrace.current);
            return Center(
              child: Column(
                children: [
                  Text(
                      "Something went wrong, please try again: ${snapshot.error}"),
                  ElevatedButton(
                      onPressed: () {
                        context.pushNamed('AuthFlow');
                      },
                      child: const Text("Try again now"))
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            _logger.d('waiting internal interaction with Firebase Auth.');
            Future.delayed(Durations.short1);
          } else if (snapshot.connectionState == ConnectionState.done) {
            _logger.d('connected to Firebase Auth server');
          } else if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;

            if (user == null) {
              context.loaderOverlay.hide();
              return const LoginPage();
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  context.loaderOverlay.hide();
                  return context.pushReplacementNamed("SettingsPage");
                } catch (e) {
                  _logger.d('-Navigation error: $e');
                }
              });
            }
          }
          context.loaderOverlay.hide();
          return const Scaffold(body: Center(child: SizedBox.shrink()));
        });
  }
}
