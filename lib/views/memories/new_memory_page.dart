/// lib/views/memories/new_memory_page.dart
///
/// a page where is meant to create new memory
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xiaokeai/components/main_view.dart';

class NewMemoryPage extends StatelessWidget {
  const NewMemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: AppLocalizations.of(context)!.addNewMemory,
        body: Center(
            child: Text(AppLocalizations.of(context)!.underDevelopment)));
  }
}
