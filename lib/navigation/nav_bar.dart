/// lib/navigation/nav_bar.dart
///
/// config the navbar and its navigation, and floating btn here

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class NavBar extends StatefulWidget {
  final Widget child;
  final bool hideNavBar;

  const NavBar({super.key, required this.child, this.hideNavBar = false});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: widget.hideNavBar
          ? null
          : NavigationBarTheme(
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
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
                indicatorColor: Theme.of(context).colorScheme.outline,
                elevation: 20,
                shadowColor: Theme.of(context).colorScheme.primaryContainer,
                indicatorShape: RoundedRectangleBorder(
                    borderRadius: UiConsts.BorderRadiusCircular_standard),
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                surfaceTintColor: Colors.amber,
                destinations: [
                  // memories
                  NavigationDestination(
                    icon: const Icon(Icons.favorite_outline_rounded),
                    selectedIcon: Icon(
                      Icons.favorite_rounded,
                      color: ThemeData.light().colorScheme.tertiaryContainer,
                    ),
                    label: "Memories",
                  ),
                  // albums
                  NavigationDestination(
                    icon: const Icon(Icons.auto_awesome_mosaic_outlined),
                    selectedIcon: Icon(
                      Icons.auto_awesome_mosaic_rounded,
                      color: ThemeData.light().colorScheme.tertiaryContainer,
                    ),
                    label: "Albums",
                  ),
                  // Anniversaries
                  NavigationDestination(
                    icon: const Icon(Icons.cake_outlined),
                    selectedIcon: Icon(
                      Icons.cake_rounded,
                      color: ThemeData.light().colorScheme.tertiaryContainer,
                    ),
                    label: "Anniversaries",
                  ),
                  // collections
                  NavigationDestination(
                    icon: const Icon(Icons.collections_bookmark_outlined),
                    selectedIcon: Icon(
                      Icons.collections_bookmark_rounded,
                      color: ThemeData.light().colorScheme.tertiaryContainer,
                    ),
                    label: "Collections",
                    tooltip: "Collections",
                  ),
                  // settings
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: Icon(
                      Icons.settings,
                      color: ThemeData.light().colorScheme.tertiaryContainer,
                    ),
                    label: "Settings",
                  ),
                ],
              ),
            ),
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
        context.goNamed("AnniversaryPage");
        break;
      case 3:
        context.goNamed("CollectionsPage");
        break;
      case 4:
        GoRouter.of(context).go('/settings');
        break;
      default:
        context.goNamed("AniversaryPage");
        break;
    }
    setState(() {
      currentIndex = index;
    });
  }
}
