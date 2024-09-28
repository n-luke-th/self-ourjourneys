/// lib/views/auth_views/auth_flow.dart
///
/// auth flow of the app

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/services/auth/acc/auth_service.dart';

class AuthFlow extends StatelessWidget {
  AuthFlow({super.key});
  final logger = Logger();

  final AuthService _auth = getIt<AuthService>();

  @override
  Widget build(BuildContext context) {
    context.loaderOverlay.show();
    return StreamBuilder<User?>(
        stream: _auth.authStateChanges,
        builder: (context, snapshot) {
          context.loaderOverlay.show();
          if (snapshot.hasError) {
            context.loaderOverlay.hide();
            logger.e("Authentication inilization error: ${snapshot.error}",
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
            logger.i('waiting internal interaction with Firebase Auth.');
            Future.delayed(Durations.short1);
          } else if (snapshot.connectionState == ConnectionState.done) {
            logger.i('connected to Firebase Auth server');
          } else if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;

            if (user == null) {
              context.loaderOverlay.hide();
              // TODO: show login page
              return const Text("login page");
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  context.loaderOverlay.hide();
                  return context.goNamed("ThaiTune");
                } catch (e) {
                  context.loaderOverlay.hide();
                  logger.d('-Navigation error: $e');
                }
              });
            }
          }
          context.loaderOverlay.hide();
          return const Scaffold(body: Center(child: SizedBox.shrink()));
        });
  }
}
