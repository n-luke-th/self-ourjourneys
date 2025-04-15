/// lib/views/memories/memories_page.dart
///
///
/// a page to show all memories
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ourjourneys/components/main_view.dart';

class MemoriesPage extends StatelessWidget {
  const MemoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: "Memories".toUpperCase(),
        showFloatingActionButton: true,
        onFloatingActionButtonPressed: () => context.pushNamed("NewMemory"),
        floatingActionButtonTooltip: "Create new memory",
        body: Center(child: Text("memories page under development")));
  }
}
