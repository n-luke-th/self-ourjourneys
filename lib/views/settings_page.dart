/// lib/views/settings_page.dart
///
/// setting page
///
// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:xiaokeai/components/main_view.dart';
import 'package:xiaokeai/helpers/dependencies_injection.dart';
import 'package:xiaokeai/helpers/logger_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xiaokeai/services/auth/acc/auth_service.dart';
import 'package:xiaokeai/services/auth/acc/auth_wrapper.dart';
import 'package:xiaokeai/services/bottom_sheet/bottom_sheet_service.dart';
import 'package:xiaokeai/services/configs/settings_service.dart';
import 'package:xiaokeai/services/configs/utils/permission_service.dart';
import 'package:xiaokeai/services/notifications/notification_manager.dart';
import 'package:xiaokeai/services/notifications/notification_service.dart';
import 'package:xiaokeai/services/package/package_info_provider.dart';
import 'package:xiaokeai/shared/views/ui_consts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthWrapper _authWrapper = getIt<AuthWrapper>();
  final Logger _logger = locator<Logger>();
  late PackageInfo packageInfo;
  final PermissionsService _permissionsService = getIt<PermissionsService>();
  late Future<Map<Permission, PermissionStatus>> _statuses;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<PackageInfoProvider>().loadPackageInfo());

    _statuses = _permissionsService.checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: AppLocalizations.of(context)!.settings,
      appbarActions: [
        IconButton(
          tooltip: AppLocalizations.of(context)!.logout,
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
                body: profileSection(),
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
              child: Text(
                  '${AppLocalizations.of(context)!.version}: ${packageInfo.version}'),
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
          return ListView(
            clipBehavior: Clip.antiAlias,
            children: [
              _accountSection(context),
              _appearanceSection(context, settings),
              _permissionSection(context)
            ],
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
            padding: UiConsts.PaddingAll_large,
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
          title: Text("Update profile"),
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
          title: Text(AppLocalizations.of(context)!.updateEmailOrPassword),
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
                          AppLocalizations.of(context)!.whatToBeUpdated,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        UiConsts.SizedBoxGapVertical_large,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ListTile(
                              title: Text(
                                  AppLocalizations.of(context)!.updateEmail),
                              onTap: () => context.pushReplacementNamed(
                                  "ReauthPage",
                                  pathParameters: <String, String>{
                                    "next": "ChangeEmailPage"
                                  }),
                            ),
                            ListTile(
                              title: Text(
                                  AppLocalizations.of(context)!.updatePassword),
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
            padding: UiConsts.PaddingAll_large,
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
          title: AppLocalizations.of(context)!.themeMode,
          value: settings.themeMode,
          items: ThemeMode.values,
          onChanged: (newValue) => _updateSetting(
            context,
            () => settings.setThemeMode(newValue),
          ),
          itemBuilder: (mode) =>
              Text(mode.toString().split('.').last.toUpperCase()),
        ),
        SettingDropdown<Locale?>(
          title: AppLocalizations.of(context)!.language,
          value: settings.currentLocaleOrNull,
          items: settings.supportedLocalesWithDefault,
          onChanged: (newValue) => _updateSetting(
            context,
            () => settings.setLocale(newValue),
          ),
          itemBuilder: (locale) =>
              Text(settings.getLanguageName(locale, context)),
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
            padding: UiConsts.PaddingAll_large,
            child: Text(
              "Permission",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize),
            ),
          ),
        ),
        ListTile(
          title: Text("Current Permission"),
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
                    'Current Permissions',
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

  Widget profileSection() {
    return Container(
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
                Align(
                  child: SizedBox.square(
                    dimension: 90,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: value.authInstance!.currentUser?.photoURL ??
                            "https://ui-avatars.com/api/?background=8FE8FF&color=fff&name=${value.authInstance!.currentUser?.email ?? 'Xiaokeai'}",
                        placeholder: (context, url) {
                          return Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        },
                        errorWidget: (context, url, error) {
                          // TODO: throw global error here
                          _logger.e(
                              "error loading img: '${error.toString()}' from '$url'",
                              error: error,
                              stackTrace: StackTrace.current);
                          return const Icon(Icons.error);
                        },
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // UiConsts.SizedBoxGapVertical_small,
                Text(
                  value.authInstance!.currentUser?.displayName ??
                      value.authInstance!.currentUser?.email ??
                      "Xiaokeai user",
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
              title: AppLocalizations.of(context)!.success,
              message: AppLocalizations.of(context)!.newChangeApplied,
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
              title: AppLocalizations.of(context)!.errorOccurred,
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
