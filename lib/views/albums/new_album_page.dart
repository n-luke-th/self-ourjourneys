/// lib/views/albums/new_album_page.dart
///
/// a page where is meant to create new memory
import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';

class NewAlbumPage extends StatelessWidget {
  const NewAlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: "Create New Album",
        body: Center(child: Text("new album page under development")));
  }
}
