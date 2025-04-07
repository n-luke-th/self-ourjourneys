/// lib/views/memories/new_memory_page.dart
///
/// a page where is meant to create new memory
import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';

class NewMemoryPage extends StatelessWidget {
  const NewMemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: "Create New Memory".toUpperCase(),
        body: Center(child: Text("new memory page under development")));
  }
}
