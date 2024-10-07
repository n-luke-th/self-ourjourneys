/// lib/views/collections/collections_page.dart
///
/// a landing page for collections feature
///
import 'package:flutter/material.dart';
import 'package:xiaokeai/components/main_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: AppLocalizations.of(context)!.collections,
        body: Center(
            child: Text(AppLocalizations.of(context)!.underDevelopment)));
  }
}
