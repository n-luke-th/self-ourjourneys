/// lib/views/albums/albums_page.dart
///
///
import 'package:flutter/material.dart';
import 'package:xiaokeai/l10n/generated/i18n/app_localizations.dart'
    show AppLocalizations;
import 'package:xiaokeai/components/main_view.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: AppLocalizations.of(context)!.albums,
        body: Center(
            child: Text(AppLocalizations.of(context)!.underDevelopment)));
  }
}
