/// lib/views/albums/albums_page.dart
///
///
import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: "Albums".toUpperCase(),
        body: Center(child: Text("albums page under development")));
  }
}
