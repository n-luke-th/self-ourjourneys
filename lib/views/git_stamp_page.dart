/// lib/views/git_stamp_page.dart
///
///
/// a simple page view to view the git stamp

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:xiaokeai/components/main_view.dart';
import 'package:xiaokeai/git_stamp/git_stamp_node.dart';
import 'package:xiaokeai/git_stamp/src/ui/git_stamp_list_tile.dart';
import 'package:xiaokeai/l10n/generated/i18n/app_localizations.dart'
    show AppLocalizations;

class MyGitStampPage extends StatelessWidget {
  const MyGitStampPage({super.key});
  String? get monospaceFontFamily {
    /// Don't forget about the font's open source license terms in Your App:
    /// https://pub.dev/packages/google_fonts#licensing-fonts
    return kIsWeb ? GoogleFonts.sourceCodePro().fontFamily : 'SourceCodePro';
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: "Git Stamps",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.version),
            subtitle: Text(GitStamp.appVersion),
            leading: const Icon(Icons.numbers),
            onTap: () {},
          ),
          GitStampListTile(monospaceFontFamily: monospaceFontFamily),
        ],
      ),
    );
  }
}
