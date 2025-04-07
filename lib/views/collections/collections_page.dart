/// lib/views/collections/collections_page.dart
///
/// a landing page for collections feature
///
import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: "Collections".toUpperCase(),
        body: Center(child: Text("Collections feature is under development!")));
  }
}
