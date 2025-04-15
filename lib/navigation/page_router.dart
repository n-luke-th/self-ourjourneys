/// lib/navigation/page_router.dart
/// config what page to be display to users
/// - page, initial route, route path, and name

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/navigation/nav_bar.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/views/albums/albums_page.dart';
import 'package:ourjourneys/views/anniversaries/anniversary_page.dart';
import 'package:ourjourneys/views/auth_views/change_password_page.dart';
import 'package:ourjourneys/views/auth_views/login_page.dart';
import 'package:ourjourneys/views/auth_views/protected_auth_view_wrapper.dart';
import 'package:ourjourneys/views/auth_views/reauth_user_page.dart';
import 'package:ourjourneys/views/auth_views/reset_password_page.dart';
import 'package:ourjourneys/views/auth_views/update_profile_page.dart';
import 'package:ourjourneys/views/collections/collections_page.dart';
import 'package:ourjourneys/views/memories/memories_page.dart';
import 'package:ourjourneys/views/memories/new_memory_page.dart';
import 'package:ourjourneys/views/settings_page.dart';

final AuthService _auth = getIt<AuthService>();

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _navbarNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nav');

const String _initialAuthLocation = '/auth';
const String _landingLocation = '/anniversaries';

final router = GoRouter(
  initialLocation: _initialAuthLocation,
  navigatorKey: _rootNavigatorKey,
  refreshListenable: _auth,
  redirect: (context, state) {
    final user = _auth.currentUser;
    final isAuthRoute = state.matchedLocation == _initialAuthLocation ||
        state.matchedLocation == '/login';

    if (user == null && !isAuthRoute) {
      return _initialAuthLocation;
    }

    if (user != null && isAuthRoute) {
      return _landingLocation;
    }

    return null;
  },
  routes: [
    ShellRoute(
      navigatorKey: _navbarNavigatorKey,
      builder: (context, state, child) {
        return NavBar(child: child);
      },
      routes: [
        // GoRoute(
        //   path: '/',
        //   name: 'HomePage',
        //   builder: (context, state) =>
        //       ProtectedAuthViewWrapper(child: const HomePage()),
        // ),
        GoRoute(
            path: _landingLocation,
            name: "AnniversaryPage",
            builder: (context, state) =>
                ProtectedAuthViewWrapper(child: const AnniversaryPage())),
        GoRoute(
            path: '/settings',
            name: 'SettingsPage',
            builder: (context, state) {
              return ProtectedAuthViewWrapper(child: const SettingsPage());
            },
            routes: [
              GoRoute(
                path: 'change-password',
                name: 'ChangePasswordPage',
                parentNavigatorKey: _navbarNavigatorKey,
                builder: (context, state) =>
                    ProtectedAuthViewWrapper(child: const ChangePasswordPage()),
              ),
              // GoRoute(
              //   path: 'change-email',
              //   name: 'ChangeEmailPage',
              //  // parentNavigatorKey: _navbarNavigatorKey,
              //   builder: (context, state) =>
              //       ProtectedAuthViewWrapper(child: const ChangeEmailPage()),
              // ),
              GoRoute(
                path: 'update-profile',
                name: 'UpdateProfilePage',
                parentNavigatorKey: _navbarNavigatorKey,
                builder: (context, state) =>
                    ProtectedAuthViewWrapper(child: const UpdateProfilePage()),
              ),
              GoRoute(
                path: 'reauth/next=:next',
                name: 'ReauthPage',
                parentNavigatorKey: _navbarNavigatorKey,
                builder: (context, state) {
                  return ProtectedAuthViewWrapper(
                    child: ReauthUserPage(
                        routeToBePushed: state.pathParameters['next']!),
                  );
                },
              ),
              // GoRoute(
              //   path: 'git-stamp',
              //   name: 'GitStampPage',
              //   parentNavigatorKey: _navbarNavigatorKey,
              //   builder: (context, state) => const MyGitStampPage(),
              // ),
            ]),
        GoRoute(
          path: '/collections',
          name: 'CollectionsPage',
          builder: (context, state) =>
              ProtectedAuthViewWrapper(child: const CollectionsPage()),
        ),
        GoRoute(
            path: '/memories',
            name: 'MemoriesPage',
            builder: (context, state) =>
                ProtectedAuthViewWrapper(child: const MemoriesPage()),
            routes: [
              GoRoute(
                path: 'new/memory',
                name: 'NewMemory',
                builder: (context, state) =>
                    ProtectedAuthViewWrapper(child: const NewMemoryPage()),
              ),
            ]),
        GoRoute(
          path: '/albums',
          name: 'AlbumsPage',
          builder: (context, state) =>
              ProtectedAuthViewWrapper(child: const AlbumsPage()),
        ),
      ],
    ),
    GoRoute(
      path: _initialAuthLocation,
      name: 'AuthPage',
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
