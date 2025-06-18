/// lib/views/settings_page.dart
///
/// setting page
///
// ignore_for_file: use_build_context_synchronously

import 'dart:async' show FutureOr;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' show GoRouterHelper;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart' show Logger;
import 'package:ourjourneys/components/method_components.dart';
import 'package:ourjourneys/helpers/get_platform_service.dart'
    show PlatformDetectionService;
import 'package:ourjourneys/services/dialog/dialog_service.dart';
import 'package:ourjourneys/shared/helpers/platform_enum.dart'
    show PlatformEnum;
import 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionStatus;
import 'package:provider/provider.dart';

import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/helpers/dependencies_injection.dart' show getIt;
import 'package:ourjourneys/services/auth/acc/auth_wrapper.dart';
import 'package:ourjourneys/services/bottom_sheet/bottom_sheet_service.dart';
import 'package:ourjourneys/services/configs/settings_service.dart';
import 'package:ourjourneys/services/configs/utils/permission_service.dart';
import 'package:ourjourneys/services/notifications/notification_manager.dart';
import 'package:ourjourneys/services/notifications/notification_service.dart';
import 'package:ourjourneys/services/package/package_info_provider.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart' show UiConsts;

/// the settings page
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final Logger _logger = getIt<Logger>();
  final PermissionsService _permissionsService = getIt<PermissionsService>();

  late Future<Map<Permission, PermissionStatus>> _statuses;
  late final String? _appVersion;
  late final String? _buildNumber;

  /// load app version and build number
  void _loadVersionAndBuildNumber() async {
    final packageInfo =
        await Provider.of<PackageInfoProvider?>(context, listen: false)
            ?.loadPackageInfoAndGet();
    if (packageInfo != null) {
      if (PlatformDetectionService.currentPlatform == PlatformEnum.iOS &&
          packageInfo.buildNumber.contains(".")) {
        _appVersion = packageInfo.version;
        _buildNumber = null;
      } else {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      }
      _logger.t("version: $_appVersion | build num: $_buildNumber");
    } else {
      _appVersion = null;
      _buildNumber = null;
      _logger.t("failed to load version and build number");
    }
  }

  @override
  void initState() {
    super.initState();
    _authWrapper.refreshAttributes();
    _loadVersionAndBuildNumber();
    _statuses = _permissionsService.requestAndCheckPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(context,
        appBarTitle: "SETTINGS",
        appbarActions: [
          IconButton(
            tooltip: "logout",
            onPressed: () async => _showLogoutConfirmation(),
            icon: Icon(
              Icons.logout_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          )
        ],
        body: buildSettingsPageBody(),
        backgroundColor: Colors.transparent);
  }

  Widget buildSettingsPageBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(flex: 2, child: profileSection()),
        Expanded(flex: 8, child: settingsListSection()),
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
          return ListView(
            clipBehavior: Clip.antiAlias,
            children: [
              _accountSection(),
              _appearanceSection(settings),
              _permissionSection(),
              _accessibilitySection(),
              _aboutSection()
            ],
          );
        },
      ),
    );
  }

  Column _accountSection() {
    return _buildSettingSection(
      "Account",
      children: [
        _buildListTile(
          "Update Profile",
          () => context.pushReplacementNamed("UpdateProfilePage"),
        ),
        _buildListTile(
          "Update Password/Email",
          () async {
            await BottomSheetService.showCustomBottomSheet(
                context: context,
                builder: (context, scroll) {
                  return Padding(
                    padding: UiConsts.PaddingAll_large,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MethodsComponents.buildBottomSheetLineDec(context),
                        Text(
                          "Update Password or Email",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const Divider(),
                        UiConsts.SizedBoxGapVertical_standard,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // TODO: implement update email back
                            // _buildListTile(
                            //   "Update email",
                            //    () => context.pushReplacementNamed(
                            //       "ReauthPage",
                            //       pathParameters: <String, String>{
                            //         "next": "ChangeEmailPage"
                            //       }),
                            // ),
                            _buildListTile(
                              "Update password",
                              () => context.pushReplacementNamed("ReauthPage",
                                  pathParameters: {
                                    'next': 'ChangePasswordPage'
                                  }),
                            )
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

  Column _appearanceSection(SettingsService settings) {
    return _buildSettingSection(
      "Appearance",
      children: [
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

  Column _permissionSection() {
    return _buildSettingSection(
      "Permissions",
      children: [
        _buildListTile(
          "Current permission status",
          () async => await BottomSheetService.showCustomBottomSheet(
            context: context,
            initialChildSize: 0.8,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Column(
                children: [
                  MethodsComponents.buildBottomSheetLineDec(context),
                  Text(
                    "Permissions status (${_permissionsService.permissionsList.length})",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
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
                            return ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: UiConsts
                                      .BorderRadiusCircular_mediumLarge),
                              title: Text(_permissionsService
                                  .getPermissionNameByPermission(permission)),
                              subtitle: Text(
                                _permissionsService.getStatusText(
                                    snapshot.data![permission] ??
                                        PermissionStatus.permanentlyDenied),
                                softWrap: true,
                              ),
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

  Column _accessibilitySection() {
    return _buildSettingSection("Accessibility",
        children: [_buildListTile("Biometric protection", () {})]);
  }

  Column _aboutSection() {
    return _buildSettingSection("About", children: [
      // _buildListTile(
      //    "Git Stamps",
      //    () {
      //     context.pushReplacementNamed("GitStampPage");
      //   },
      //
      // _buildListTile(
      //    "Privacy Policy",
      //    () {
      //     context.pushReplacementNamed("PrivacyPolicyPage");
      //   },
      //
      // ),
      // _buildListTile(
      //    "Terms of Service"),
      //    () {
      //     context.pushReplacementNamed("TermsOfServicePage");
      //   },
      //
      // ),
      _buildListTile(
          "Licenses",
          () => showLicensePage(
              context: context, applicationVersion: _appVersion)),
      _buildListTile("Version", () async {
        if (_appVersion != null) {
          await DialogService.showInfoDialog(
              context: context,
              title: "App Version",
              message:
                  "${"Version: $_appVersion"}${_buildNumber != null ? _buildNumber.isEmpty ? "" : "\nBuild Number: $_buildNumber" : ""}");
        } else {
          await DialogService.showInfoDialog(
              context: context,
              title: "App Version",
              message:
                  "Unable to retrieve version information, please try again later.");
        }
      }),
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
        child: Padding(
          padding: UiConsts.PaddingAll_standard,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UiConsts.SizedBoxGapVertical_small,
              Text(
                _authWrapper.displayName == "_OurJourneys user_"
                    ? _authWrapper.emailAddress
                    : _authWrapper.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ));
  }

  Column _buildSettingSection(String title,
      {List<Widget> children = const [], TextStyle? style}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: UiConsts.PaddingAll_standard,
            child:
                Text(title, style: style ?? _getSettingSectionTitleTextStyle()),
          ),
        ),
        ...children
      ],
    );
  }

  TextStyle _getSettingSectionTitleTextStyle() {
    return TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
        fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize);
  }

  Future<void> _showLogoutConfirmation() async {
    await _authWrapper.handleLogout(context);
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
    return _buildListTile(
      widget.title,
      () {
        BottomSheetService.showCustomBottomSheet(
          context: context,
          builder: (_, scrollController) => Column(
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
        );
      },
      trailing: _isChanging
          ? LoadingAnimationWidget.beat(
              color: Theme.of(context).colorScheme.onSurface, size: 22)
          : MethodsComponents.buildSettingPageTakeOnActionBtn(
              children: [widget.itemBuilder(widget.value)]),
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
      padding: UiConsts.PaddingAll_standard,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(UiConsts.borderRadius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MethodsComponents.buildBottomSheetLineDec(context),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Divider(),
          UiConsts.SizedBoxGapVertical_standard,
          ...items.map((item) => ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: UiConsts.BorderRadiusCircular_mediumLarge),
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
    // TODO: add the app custom exception
    context.read<NotificationManager>().showNotification(
          context,
          NotificationData(
              title: "Update Failed",
              message: 'error details',
              type: CustomNotificationType.error),
        );
  }
}

ListTile _buildListTile(String title, FutureOr<void> Function()? onTap,
    {Widget? trailing}) {
  return ListTile(
    // hoverColor: Colors.tealAccent,
    // shape: RoundedSuperellipseBorder(
    //     borderRadius: UiConsts.BorderRadiusCircular_medium),
    shape: RoundedRectangleBorder(
        borderRadius: UiConsts.BorderRadiusCircular_mediumLarge),
    enableFeedback: true,
    title: Text((title)),
    trailing: trailing ?? MethodsComponents.buildSettingPageTakeOnActionBtn(),
    onTap: () async => await onTap?.call(),
  );
}
