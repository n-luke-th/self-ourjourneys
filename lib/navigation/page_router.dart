/// lib/navigation/page_router.dart
/// config what page to be display to users
/// - page, initial route, route path, and name

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xiaokeai/navigation/nav_bar.dart';
import 'package:xiaokeai/views/albums/albums_page.dart';
import 'package:xiaokeai/views/auth_views/auth_flow.dart';
import 'package:xiaokeai/views/auth_views/login_page.dart';
import 'package:xiaokeai/views/home_page.dart';
import 'package:xiaokeai/views/memories/memories_page.dart';
import 'package:xiaokeai/views/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return NavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'HomePage',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/settings',
          name: 'SettingsPage',
          builder: (context, state) => SettingsPage(),
        ),
        GoRoute(
          path: '/memories',
          name: 'MemoriesPage',
          builder: (context, state) => MemoriesPage(),
        ),
        GoRoute(
          path: '/albums',
          name: 'AlbumsPage',
          builder: (context, state) => AlbumsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      name: 'AuthFlow',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => AuthFlow(),
    ),
    GoRoute(
      path: '/login',
      name: 'LoginPage',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => LoginPage(),
    ),
    // GoRoute(
    //   path: '/reset-password',
    //   name: 'ResetPasswordPage',
    //   parentNavigatorKey: _rootNavigatorKey,
    //   builder: (context, state) => const ResetPasswordPage(),
    // ),

    GoRoute(
      path: '/new/memory',
      name: 'NewMemory',
      // parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const Text("NewMemory"),
    ),
  ],
);
