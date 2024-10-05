# xiaokeai

## Getting Started

0. make sure you have config the latest changes of the app by run command: `git pull`

1. run `flutter clean && flutter pub get` to clean up and get dependencies

2. run `dart run git_stamp` to generate most recent git info (LTE version)

3. run app on another terminal by using command `flutter run -d chrome --web-port 5555` (this will run on Chrome with port 5555)

## Notable config

### Splash screen

- config the [`native_splash.yaml`](native_splash.yaml) file then
- (everytime after changes were made) regenerate the splash screen based on the [`native_splash.yaml`](native_splash.yaml) file by run command: `dart run flutter_native_splash:create --path=native_splash.yaml`

### Launcher icon

- config the [`launcher_icons.yaml`](launcher_icons.yaml) file then
- (everytime after changes were made) regenerate the launcher icon based on the [`launcher_icons.yaml`](launcher_icons.yaml) file by run command: `dart run icons_launcher:create --path launcher_icons.yaml`

### l10n

- edit the `.arb` files in the [`lib/l10n`](lib/l10n) folder and then run `flutter gen-l10n` everytime after that
