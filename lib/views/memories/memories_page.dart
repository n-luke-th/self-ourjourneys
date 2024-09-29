/// lib/views/memories/memories_page.dart
///
///
///
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xiaokeai/components/main_view.dart';

class MemoriesPage extends StatelessWidget {
  const MemoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: AppLocalizations.of(context)!.memories,
        body: Center(
            child: Text(AppLocalizations.of(context)!.underDevelopment)));
  }
}
