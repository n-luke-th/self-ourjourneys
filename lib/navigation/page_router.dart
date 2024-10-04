/// lib/navigation/page_router.dart
/// config what page to be display to users
/// - page, initial route, route path, and name

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xiaokeai/navigation/nav_bar.dart';
import 'package:xiaokeai/views/albums/albums_page.dart';
import 'package:xiaokeai/views/auth_views/auth_flow.dart';
import 'package:xiaokeai/views/auth_views/change_email_page.dart';
import 'package:xiaokeai/views/auth_views/change_password_page.dart';
import 'package:xiaokeai/views/auth_views/login_page.dart';
import 'package:xiaokeai/views/auth_views/reauth_user_page.dart';
import 'package:xiaokeai/views/auth_views/reset_password_page.dart';
import 'package:xiaokeai/views/auth_views/update_profile_page.dart';
import 'package:xiaokeai/views/home_page.dart';
import 'package:xiaokeai/views/memories/memories_page.dart';
import 'package:xiaokeai/views/memories/new_memory_page.dart';
import 'package:xiaokeai/views/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _navbarNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nav');

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _navbarNavigatorKey,
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
            builder: (context, state) {
              state.pathParameters['next'];
              return SettingsPage();
            },
            routes: [
              GoRoute(
                path: 'change-password',
                name: 'ChangePasswordPage',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ChangePasswordPage(),
              ),
              GoRoute(
                path: 'change-email',
                name: 'ChangeEmailPage',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const ChangeEmailPage(),
              ),
              GoRoute(
                path: 'update-profile',
                name: 'UpdateProfilePage',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const UpdateProfilePage(),
              ),
              GoRoute(
                path: 'reauth',
                name: 'ReauthPage',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  state.pathParameters['next'];
                  return ReauthUserPage(
                      routeToBePushed: state.pathParameters['next']!);
                },
              ),
            ]),
        GoRoute(
            path: '/memories',
            name: 'MemoriesPage',
            builder: (context, state) => MemoriesPage(),
            routes: [
              GoRoute(
                path: 'new/memory',
                name: 'NewMemory',
                builder: (context, state) => NewMemoryPage(),
              ),
            ]),
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
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'ResetPasswordPage',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ResetPasswordPage(),
    ),
  ],
);
