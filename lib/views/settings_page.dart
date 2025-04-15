/// lib/views/settings_page.dart
///
/// setting page
///
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart';
import 'package:ourjourneys/services/auth/acc/auth_service.dart';
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/bottom_sheet/bottom_sheet_service.dart';
import 'package:ourjourneys/services/configs/settings_service.dart';
import 'package:ourjourneys/services/configs/utils/permission_service.dart';
import 'package:ourjourneys/services/notifications/notification_manager.dart';
import 'package:ourjourneys/services/notifications/notification_service.dart';
import 'package:ourjourneys/services/package/package_info_provider.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final Logger _logger = getIt<Logger>();
  final PermissionsService _permissionsService = getIt<PermissionsService>();
  late PackageInfo packageInfo;
  late Future<Map<Permission, PermissionStatus>> _statuses;

  @override
  void initState() {
    super.initState();
    // _authWrapper.handleRefreshUser();
    Future.microtask(
        () => context.read<PackageInfoProvider>().loadPackageInfo());

    _statuses = _permissionsService.checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: "Settings".toUpperCase(),
      appbarActions: [
        IconButton(
          tooltip: "logout",
          onPressed: () async => _showLogoutConfirmation(context),
          icon: Icon(
            Icons.logout_outlined,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        )
      ],
      body: buildSettingsPageBody(),
    );
  }

  Column buildSettingsPageBody() {
    // ignore: no_leading_underscores_for_local_identifiers
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
            flex: 2,
            child: Scaffold(
                extendBody: true,
                body: Padding(
                  padding: UiConsts.PaddingHorizontal_large,
                  child: profileSection(),
                ),
                extendBodyBehindAppBar: true)),
        Expanded(
            flex: 5,
            child: Scaffold(
              body: settingsListSection(),
              extendBody: true,
              extendBodyBehindAppBar: true,
            )),
        Consumer<PackageInfoProvider>(builder: (context, provider, child) {
          final packageInfo = provider.packageInfo;

          if (packageInfo == null) {
            return const Center(child: Text("No version found!"));
          }
          _logger.i(
              "version: ${packageInfo.version} | build num: ${packageInfo.buildNumber}");
          return Padding(
            padding: UiConsts.PaddingAll_standard,
            child: Center(
              child: Text('version: ${packageInfo.version}'),
            ),
          );
        })
      ],
    );
  }

  Container settingsListSection() {
    return Container(
      margin: EdgeInsets.only(top: UiConsts.margin_standard),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.vertical(
            top: Radius.elliptical(
                UiConsts.borderRadius, UiConsts.borderRadius)),
      ),
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return Padding(
            padding: UiConsts.PaddingBottom_extraLarge,
            child: ListView(
              clipBehavior: Clip.antiAlias,
              children: [
                _accountSection(context),
                _appearanceSection(context, settings),
                _permissionSection(context),
                _accessibilitySection(context),
                _aboutSection(context)
              ],
            ),
          );
        },
      ),
    );
  }

  Column _accountSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: UiConsts.PaddingAll_standard,
            child: Text(
              "Account",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize),
            ),
          ),
        ),
        ListTile(
          title: const Text("Update Profile"),
          onTap: () => context.pushReplacementNamed("UpdateProfilePage"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UiConsts.spaceForTextAndElement,
              const Icon(Icons.arrow_forward_ios, size: UiConsts.smallIconSize),
            ],
          ),
        ),
        ListTile(
          title: Text("Update Password/Email"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UiConsts.spaceForTextAndElement,
              const Icon(Icons.arrow_forward_ios, size: UiConsts.smallIconSize),
            ],
          ),
          onTap: () {
            BottomSheetService.showCustomBottomSheet(
                context: context,
                builder: (context, scroll) {
                  return Container(
                    padding: UiConsts.PaddingAll_large,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(UiConsts.borderRadius)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                            borderRadius:
                                UiConsts.BorderRadiusCircular_standard,
                          ),
                        ),
                        Text(
                          "Update Password or Email",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        UiConsts.SizedBoxGapVertical_large,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // TODO: implement update email back
                            // ListTile(
                            //   title: Text("Update email"),
                            //   onTap: () => context.pushReplacementNamed(
                            //       "ReauthPage",
                            //       pathParameters: <String, String>{
                            //         "next": "ChangeEmailPage"
                            //       }),
                            // ),
                            ListTile(
                              title: const Text("Update password"),
                              onTap: () => context.pushReplacementNamed(
                                  "ReauthPage",
                                  pathParameters: {
                                    'next': 'ChangePasswordPage'
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                });
          },
        ),
      ],
    );
  }

  Column _appearanceSection(BuildContext context, SettingsService settings) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: UiConsts.PaddingAll_standard,
            child: Text(
              "Appearance",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize),
            ),
          ),
        ),
        SettingDropdown<ThemeMode>(
          title: "Theme mode",
          value: settings.themeMode,
          items: ThemeMode.values,
          onChanged: (newValue) => _updateSetting(
            context,
            () => settings.setThemeMode(newValue),
          ),
          itemBuilder: (mode) =>
              Text(mode.toString().split('.').last.toUpperCase()),
        ),
      ],
    );
  }

  Column _permissionSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: UiConsts.PaddingAll_standard,
            child: Text(
              "Permissions",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize),
            ),
          ),
        ),
        ListTile(
          title: const Text("Current permission status"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UiConsts.spaceForTextAndElement,
              const Icon(Icons.arrow_forward_ios, size: UiConsts.smallIconSize),
            ],
          ),
          onTap: () => BottomSheetService.showCustomBottomSheet(
            context: context,
            initialChildSize: 0.6,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Text(
                    "Current permission status",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Divider(),
                  StreamBuilder(
                    stream: _statuses.asStream(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<Permission, PermissionStatus>>
                            snapshot) {
                      context.loaderOverlay.show();
                      if (snapshot.connectionState == ConnectionState.done) {
                        context.loaderOverlay.hide();
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: _permissionsService.permissionsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            Permission permission =
                                _permissionsService.permissionsList[index];
                            PermissionStatus status =
                                snapshot.data![permission] ??
                                    PermissionStatus.permanentlyDenied;
                            String statusText =
                                _permissionsService.getStatusText(status);

                            return ListTile(
                              title: Text(permission.toString()),
                              subtitle: Text(statusText),
                            );
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
              );
            },
            isDraggable: true,
            isDismissible: true,
            snapAnimationDuration: const Duration(milliseconds: 500),
          ),
        ),
      ],
    );
  }

  Column _accessibilitySection(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: UiConsts.PaddingAll_standard,
          child: Text(
            "Accessibility",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize),
          ),
        ),
      ),
      ListTile(
        title: const Text("Biometric protection"),
        onTap: () => {},
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiConsts.spaceForTextAndElement,
            const Icon(Icons.arrow_forward_ios, size: UiConsts.smallIconSize),
          ],
        ),
      ),
    ]);
  }

  Column _aboutSection(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: UiConsts.PaddingAll_standard,
          child: Text(
            "About",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize),
          ),
        ),
      ),
      // ListTile(
      //   title: const Text("Git Stamps"),
      //   onTap: () {
      //     context.pushReplacementNamed("GitStampPage");
      //   },
      //   trailing: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       UiConsts.spaceForTextAndElement,
      //       const Icon(Icons.arrow_forward_ios, size: UiConsts.smallIconSize),
      //     ],
      //   ),
      // ),
      // ListTile(
      //   title: Text("Privacy Policy"),
      //   onTap: () {
      //     context.pushReplacementNamed("PrivacyPolicyPage");
      //   },
      //   trailing: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       UiConsts.spaceForTextAndElement,
      //       const Icon(Icons.arrow_forward_ios, size: UiConsts.smallIconSize),
      //     ],
      //   ),
      // ),
      // ListTile(
      //   title: Text("Terms of Service"),
      //   onTap: () {
      //     context.pushReplacementNamed("TermsOfServicePage");
      //   },
      //   trailing: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       UiConsts.spaceForTextAndElement,
      //       const Icon(Icons.arrow_forward_ios, size: UiConsts.smallIconSize),
      //     ],
      //   ),
      // ),
      ListTile(
        title: const Text("Licenses"),
        onTap: () {
          showLicensePage(context: context);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiConsts.spaceForTextAndElement,
            const Icon(Icons.arrow_forward_ios, size: UiConsts.smallIconSize),
          ],
        ),
      ),
    ]);
  }

  Container profileSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(
                UiConsts.borderRadius_large, UiConsts.borderRadius_large)),
        gradient: LinearGradient(
            begin: AlignmentDirectional.topCenter,
            end: AlignmentDirectional.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.errorContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ]),
      ),
      child: Consumer<AuthService>(
        builder: (BuildContext context, AuthService value, Widget? child) {
          return Padding(
            padding: UiConsts.PaddingAll_standard,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // UiConsts.SizedBoxGapVertical_small,
                Text(
                  value.authInstance!.currentUser?.displayName ??
                      value.authInstance!.currentUser?.email ??
                      "OurJourneys user",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    await _authWrapper.handleLogout(context);
  }
}

Future<void> _updateSetting(
    BuildContext context, Future<bool> Function() updateFunction) async {
  try {
    bool success = await updateFunction();
    if (success) {
      context.read<NotificationManager>().showNotification(
            context,
            NotificationData(
              title: "New Change Applied",
              message: "Your setting has been updated",
              type: CustomNotificationType.success,
            ),
          );
    } else {
      throw Exception('Failed to update setting');
    }
  } catch (e) {
    // TODO: add the global exception
    context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: "Update Failed",
              message: 'error details',
              type: CustomNotificationType.error),
        );
  }
}

class SettingDropdown<T> extends StatefulWidget {
  final String title;
  final T value;
  final List<T> items;
  final Future<void> Function(T) onChanged;
  final Widget Function(T) itemBuilder;
  final Widget? previewButton;

  const SettingDropdown({
    super.key,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.previewButton,
  });

  @override
  State<SettingDropdown> createState() => _SettingDropdownState<T>();
}

class _SettingDropdownState<T> extends State<SettingDropdown<T>> {
  bool _isChanging = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      trailing: _isChanging
          ? LoadingAnimationWidget.beat(
              color: Theme.of(context).colorScheme.onSurface, size: 22)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.itemBuilder(widget.value),
                UiConsts.spaceForTextAndElement,
                const Icon(Icons.arrow_forward_ios,
                    size: UiConsts.smallIconSize),
              ],
            ),
      onTap: () {
        BottomSheetService.showCustomBottomSheet(
          context: context,
          builder: (_, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                SettingBottomSheet<T>(
                  title: widget.title,
                  value: widget.value,
                  items: widget.items,
                  onChanged: (T newValue) async {
                    setState(() => _isChanging = true);
                    await widget.onChanged(newValue);
                    setState(() => _isChanging = false);
                  },
                  itemBuilder: widget.itemBuilder,
                ),
                if (widget.previewButton != null) widget.previewButton!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class SettingBottomSheet<T> extends StatelessWidget {
  final String title;
  final T value;
  final List<T> items;
  final Future<void> Function(T) onChanged;
  final Widget Function(T) itemBuilder;

  const SettingBottomSheet({
    super.key,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: UiConsts.PaddingAll_large,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(UiConsts.borderRadius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: UiConsts.BorderRadiusCircular_standard,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          UiConsts.SizedBoxGapVertical_large,
          ...items.map((item) => ListTile(
                title: itemBuilder(item),
                onTap: () async {
                  await onChanged(item);
                  Navigator.pop(context);
                },
                trailing: value == item ? const Icon(Icons.check) : null,
              )),
        ],
      ),
    );
  }
}
