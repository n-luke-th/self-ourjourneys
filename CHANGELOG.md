# OurJourneys by LukeCreated release history

Starting with version **`0.3.18`** (2025-06-18), the release history is adapting the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) version **1.1.0** format, and will slowly convert the old logs to the new format. However, the old logs will remain available for reference in the [LEGACY-CHANGELOG.md](LEGACY-CHANGELOG.md) file.

## Roadmap

- [roadmap](https://github.com/n-luke-th/self-ourjourneys/issues/1#issue-2957903497)

## [Unreleased]

- Upcoming major features can be found in the [roadmap](#roadmap).
- Refactor the codebase to use `Riverpod` as well as to be more readable and maintainable.
- Complete the possible method actions on `album_details_page.dart` such as adding items, unlinking items, permanently delete items from the album and server are now efficiently implemented.
- Adjustment of UI/UX for **Album** feature page.
- New dialog and toast system (notification) for the application.
- Reordered bottom navigation bar items, and the new home page for the application that shows the available function menus.
- Add checksum verification between each to be uploaded selected local files to ensure the integrity of the files.

## Initial Development: [`0.3.21`] - 2025-07-04

### Added

- `LocalAndServerFileSelectionProvider` as the state tracking and data provider for editing the selected files for associated further actions like create new albums with the selected files and uploading the selected files.

### Changed

- General improvements.
- Enchanced `server_file_selector.dart`.
- Refactored to use `Provider` for create new album process.

### Deprecated

- none

### Removed

- none

### Fixed

- none

### Others

- Upgrade dependency constraints: new dependency `flutter_riverpod` added for upcoming codebase refactor to use `Riverpod`, `go_router` to `16.0.0`, `get_time_ago` to `2.3.2`, `firebase_core` to `3.15.1`, `cloud_firestore` to `5.6.11`, `firebase_auth` to `5.6.2`, ,`firebase_messaging` to `15.2.9`, `chewie` to `1.12.1`,`permission_handler` to `12.0.1` , and other transitive dependencies.

## Initial Development: [`0.3.20`] - 2025-06-28

### Added

- Method action on `album_details_page.dart` for unlinking items is implemented but still needed to be improved and optimized for UI/UX.
- Ability to on-demand retry loading the media items from the server.

### Changed

- General improvements.
- Server files selector is now in the enchancement process on the rendering system.

### Deprecated

- none

### Removed

- none

### Fixed

- none

### Others

- Upgrade dependency constraints: [transitive] `posix` to `6.0.3`.

## Initial Development: [`0.3.19`] - 2025-06-27

### Added

- `MediaRenderingException` class and related error enums are added for handling the media rendering exception.
- `ImageProviderCache` as the provider class for the internal image rendering system.
- `AlbumDetailsProvider` as the state tracking and data provider for `album_details_page.dart`.

### Changed

- Improved the image rendering system which enchanced the performance.
- Combined the all the actions on `full_media_view.dart` into the `MoreActionsBtn` widget.
- Improved internal code for the `album_details_page.dart` page.
- On `album_details_page.dart` can now efficiently selecting/deselecting items for further actions.
- General improvements.

### Deprecated

- none

### Removed

- none

### Fixed

- none

### Others

- Upgrade dependency constraints: `go_router` to `15.2.4`, `form_builder_validators` to `11.2.0`, `logger` to `2.6.0`, and [transitive] `synchronized` to `3.4.0`.

## Initial Development: [`0.3.18`] - 2025-06-18

### Added

- none

### Changed

- Improved the created and last modified date and time string generation.
- Moved the `all_files_page.dart` and `full_media_view.dart` out from the album folder to media folder.
- Code refactored for `settings_page.dart` for improvements and readability.
- Overall theme and color scheme adjustments.
- Used the error builder for `MediaItemContainer` when there is error loading image instead of default error widget from `ImageDisplayConfigsModel`.
- UI/UX adjustment for `album_details_page.dart` as well as implementing its sub functions: selecting items, adding items, removing items, permanently delete items from the album and server.
- Converted `MediaItemContainer` to be a stateless widget.
- General improvements.

### Deprecated

- none

### Removed

- `ActionWidgetPlace` enum is removed and replaced with Flutter's `Alignment` class in `MediaItemContainer` class.
- `MediaItemContainer`'s `onHover` callback is unavailable as well as hovering effects.

### Fixed

- none

### Others

- Update dependency constraints: converted `crypto` from transitive dependency to direct dependency.

## Initial Development: [`0.3.17`] - 2025-06-16

### Added

- Enabled `const` modifiers for the data models.
- Version number is now shown in the license page if available.
- New dedicated category utility class `InterfaceUtils` for the interface related utilities.
- Introduced new enum `PageMode` for the page mode tracking; view or edit mode.

### Changed

- Improving the UI/UX of the **Album** feature pages.
- Adjusting the internal data gathering for albums page and album details page for **Album** feature pages.
- Code refactored for settings page for improvements and readability.
- General improvements.

### Deprecated

- none

### Removed

- none

### Fixed

- none

### Others

- Version and build number retrieval adjustment for setting page and `main.dart` page.
- Update dependency constraints: new dependency `marquee` added for the marquee text.

## Initial Development: [`0.3.16`] - 2025-06-14

### Added

- Dedicated 3 image providers `localFileImageProvider` for rendering file-based image and ensure no errors when building the application for platform dependent libraries.

### Changed

- General improvements.

### Deprecated

- none

### Removed

- none

### Fixed

- Ensure compatibility for image rendering system for web by rendering from bytes.

### Others

- Upgrade dependency constraints: `go_router` to `15.2.0`.

# TODO: Complete the release history logs of the previous versions.

## Initial Development: [`0.3.15`] - 2025-06-12

### Added

- none

### Changed

- General improvements.

### Deprecated

- none

### Removed

- none

### Fixed

- none

### Others

- Update dependency constraints: .

## Initial Development: [`0.3.14`] - 2025-06-12

### Added

- none

### Changed

- General improvements.

### Deprecated

- none

### Removed

- none

### Fixed

- none

### Others

- none
