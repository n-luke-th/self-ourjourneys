/// lib/views/home_page.dart
/// home page view

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xiaokeai/components/main_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: AppLocalizations.of(context)!.home,
        body: Center(child: Text(AppLocalizations.of(context)!.home)));
  }
}
