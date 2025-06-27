/// lib/navigation/page_router.dart
/// config what page to be display to users
/// - page, initial route, route path, and name

import 'package:flutter/material.dart' show GlobalKey, NavigatorState;
import 'package:go_router/go_router.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/models/db/albums_model.dart';
import 'package:ourjourneys/navigation/nav_bar.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/services/core/album_details_provider.dart';
import 'package:ourjourneys/views/albums/album_details_page.dart';
import 'package:ourjourneys/views/albums/albums_page.dart';
import 'package:ourjourneys/views/media/all_files_page.dart';
import 'package:ourjourneys/views/albums/new_album_page.dart';
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
import 'package:provider/provider.dart' show ChangeNotifierProvider;

final AuthService _auth = getIt<AuthService>();

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _navbarNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nav');

const String _initialAuthLocation = '/auth';
const String _landingLocation = '/anniversaries';
const String _resetPasswordLocation = '/reset-password';

final router = GoRouter(
  initialLocation: _initialAuthLocation,
  navigatorKey: _rootNavigatorKey,
  refreshListenable: _auth,
  redirect: (context, state) {
    final user = _auth.currentUser;
    final isAuthRoute = state.matchedLocation == _initialAuthLocation ||
        state.matchedLocation == '/login';

    if (state.matchedLocation == _resetPasswordLocation && user == null) {
      return _resetPasswordLocation;
    }

    if (state.matchedLocation == '/' && user == null) {
      return _initialAuthLocation;
    }

    if (user != null && state.matchedLocation == '/') {
      return _landingLocation;
    }

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
        if (state.topRoute!.name == "ReauthPage" ||
            state.topRoute!.name == "ChangePasswordPage" ||
            state.topRoute!.name == "ResetPasswordPage" ||
            state.topRoute!.name == "NewAlbumPage" ||
            state.topRoute!.name == "NewMemoryPage" ||
            state.topRoute!.name == "AlbumDetailsPage") {
          return NavBar(
            hideNavBar: true,
            child: child,
          );
        } else {
          return NavBar(child: child);
        }
      },
      routes: [
        // GoRoute(
        //   path: '/',
        //   name: 'HomePage',
        //   builder: (context, state) =>
        //       ProtectedAuthViewWrapper(child: const HomePage()),
        // ),
        GoRoute(

            /// '/anniversaries'
            path: _landingLocation,
            name: "AnniversaryPage",
            builder: (context, state) =>
                ProtectedAuthViewWrapper(child: const AnniversaryPage())),
        GoRoute(

            /// '/settings'
            path: '/settings',
            name: 'SettingsPage',
            builder: (context, state) {
              return ProtectedAuthViewWrapper(child: const SettingsPage());
            },
            routes: [
              GoRoute(
                /// '/settings/change-password'
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
                /// '/settings/update-profile'
                path: 'update-profile',
                name: 'UpdateProfilePage',
                parentNavigatorKey: _navbarNavigatorKey,
                builder: (context, state) =>
                    ProtectedAuthViewWrapper(child: const UpdateProfilePage()),
              ),
              GoRoute(
                /// '/settings/reauth/next=:next',
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
          /// '/collections'
          path: '/collections',
          name: 'CollectionsPage',
          builder: (context, state) =>
              ProtectedAuthViewWrapper(child: const CollectionsPage()),
        ),
        GoRoute(

            /// '/memories'
            path: '/memories',
            name: 'MemoriesPage',
            builder: (context, state) =>
                ProtectedAuthViewWrapper(child: const MemoriesPage()),
            routes: [
              GoRoute(
                /// '/memories/new/memory'
                path: 'new/memory',
                name: 'NewMemoryPage',
                builder: (context, state) =>
                    ProtectedAuthViewWrapper(child: const NewMemoryPage()),
              ),
            ]),

        GoRoute(

            /// '/albums'
            path: '/albums',
            name: 'AlbumsPage',
            builder: (context, state) =>
                ProtectedAuthViewWrapper(child: const AlbumsPage()),
            routes: [
              GoRoute(
                /// '/albums/new/album'
                path: 'new/album',
                name: 'NewAlbumPage',
                builder: (context, state) =>
                    ProtectedAuthViewWrapper(child: const NewAlbumPage()),
              ),
              GoRoute(
                /// '/albums/album-details'
                path: 'album-details',
                name: 'AlbumDetailsPage',
                builder: (context, state) => ProtectedAuthViewWrapper(
                    child:
                        // Album state & selection
                        ChangeNotifierProvider<AlbumDetailsProvider>(
                  create: (_) =>
                      AlbumDetailsProvider(state.extra as AlbumsModel?),

                  // UI subtree that can read / watch required provider(s).
                  builder: (_, child) => const AlbumDetailsPage(),
                )),
              ),
            ]),
      ],
    ),
    GoRoute(
      /// '/auth'
      path: _initialAuthLocation,
      name: 'AuthPage',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      /// '/reset-password'
      path: _resetPasswordLocation,
      name: 'ResetPasswordPage',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      /// '/view-all-files'
      path: '/view-all-files',
      name: 'ViewAllFilesPage',
      builder: (context, state) =>
          ProtectedAuthViewWrapper(child: const AllFilesPage()),
    ),
  ],
);
