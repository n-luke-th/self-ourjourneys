/// lib/views/home_page.dart
/// home page view

import 'package:flutter/material.dart';
import 'package:xiaokeai/components/main_view.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/l10n/generated/i18n/app_localizations.dart'
    show AppLocalizations;
import 'package:xiaokeai/services/auth/acc/auth_wrapper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();

  @override
  void initState() {
    super.initState();
    _authWrapper.handleRefreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: AppLocalizations.of(context)!.home,
        body: Center(child: Text(AppLocalizations.of(context)!.home)));
  }
}
