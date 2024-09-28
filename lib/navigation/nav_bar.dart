/// lib/navigation/nav_bar.dart
///
/// config the navbar and its navigation here

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NavBar extends StatefulWidget {
  final Widget child;

  const NavBar({super.key, required this.child});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int idx) => _onItemTapped(idx, context),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: 'Home' // AppLocalizations.of(context)!.heading_home,
              ),
          NavigationDestination(
              icon: const Icon(Icons.receipt_outlined),
              selectedIcon: const Icon(Icons.receipt),
              label:
                  'Memories' // AppLocalizations.of(context)!.heading_records,
              ),
          NavigationDestination(
              icon: const Icon(Icons.analytics_outlined),
              selectedIcon: const Icon(Icons.analytics),
              label:
                  'Albums' // AppLocalizations.of(context)!.heading_analytics,
              ),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label:
                  'Settings' // AppLocalizations.of(context)!.heading_settings,
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip:
            'Add new memory', // AppLocalizations.of(context)!.heading_addNewTransaction,
        onPressed: () => context.pushNamed('NewMemory'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed("HomePage");
        break;
      case 1:
        GoRouter.of(context).go('/memories');
        break;
      case 2:
        GoRouter.of(context).go('/albums');
        break;
      case 3:
        GoRouter.of(context).go('/settings');
        break;
    }
    setState(() {
      currentIndex = index;
    });
  }
}
