/// lib/views/memories/memories_page.dart
///
///
/// a page to show all memories
import 'package:flutter/material.dart';
import 'package:xiaokeai/l10n/generated/i18n/app_localizations.dart'
    show AppLocalizations;
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
