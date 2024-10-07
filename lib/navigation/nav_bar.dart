/// lib/navigation/nav_bar.dart
///
/// config the navbar and its navigation, and floating btn here

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xiaokeai/shared/views/ui_consts.dart';

class NavBar extends StatefulWidget {
  final Widget child;

  const NavBar({super.key, required this.child});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
              return TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              );
            },
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (int idx) => _onItemTapped(idx, context),
          animationDuration: Durations.long4,
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          indicatorColor: Theme.of(context).colorScheme.outline,
          elevation: 20,
          shadowColor: Theme.of(context).colorScheme.primaryContainer,
          indicatorShape: RoundedRectangleBorder(
              borderRadius: UiConsts.BorderRadiusCircular_standard),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          surfaceTintColor: Colors.amber,
          destinations: [
            // memories
            NavigationDestination(
              icon: const Icon(Icons.favorite_outline_rounded),
              selectedIcon: Icon(
                Icons.favorite_rounded,
                color: ThemeData.light().colorScheme.tertiaryContainer,
              ),
              label: AppLocalizations.of(context)!.memories,
            ),
            // albums
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_mosaic_outlined),
              selectedIcon: Icon(
                Icons.auto_awesome_mosaic_rounded,
                color: ThemeData.light().colorScheme.tertiaryContainer,
              ),
              label: AppLocalizations.of(context)!.albums,
            ),
            // home
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(
                Icons.home,
                color: ThemeData.light().colorScheme.tertiaryContainer,
              ),
              label: AppLocalizations.of(context)!.home,
            ),
            // collections
            NavigationDestination(
              icon: const Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(
                Icons.collections_bookmark_rounded,
                color: ThemeData.light().colorScheme.tertiaryContainer,
              ),
              label: AppLocalizations.of(context)!.collections,
            ),
            // settings
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: Icon(
                Icons.settings,
                color: ThemeData.light().colorScheme.tertiaryContainer,
              ),
              label: AppLocalizations.of(context)!.settings,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.of(context)!.addNewMemory,
        onPressed: () => context.pushNamed('NewMemory'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/memories');
        break;
      case 1:
        GoRouter.of(context).go('/albums');
        break;
      case 2:
        context.goNamed("HomePage");
        break;
      case 3:
        context.goNamed("CollectionsPage");
        break;
      case 4:
        GoRouter.of(context).go('/settings');
        break;
      default:
        context.goNamed("HomePage");
        break;
    }
    setState(() {
      currentIndex = index;
    });
  }
}
