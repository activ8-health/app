# Activ8 - Frontend

The frontend for Activ8 is written in Flutter, and consists of multiple workflows:

- Registration Pages
    - Sign-in Pages (branch/shared)
- Home Page
    - Food Page
        - Food Log Page
    - Exercise Page
    - Sleep Page

## Build

To build for iOS, you need to have macOS and Xcode set up.

1. Install [Flutter](https://flutter.dev/docs/get-started/install) and [git](https://git-scm.com/)
    - Use `flutter doctor -v` to make sure everything works
2. Clone this repository and enter the directory
    - `git clone https://github.com/tristanphan/cs125`
    - `cd cs125/app/`
3. Get dependencies with `flutter pub get`
4. Generate injectables with `flutter pub run build_runner build`
5. Build or Run (use `--debug` and `--release` as necessary)
    - Run on a device/simulator with `flutter run`
    - Sideloading: see below

### Sideloading

If you wish to install Activ8 as a real app, one option is to sideload it.

1. Build using `flutter build ipa`
2. If you have a paid Apple Developer account, you can create an `IPA` file directly by creating an Archive in Xcode and
   using the Export option.
    - If you only have a free account, here's a workaround:
        - Use `flutter run` to run the app on an iOS simulator
        - Copy `build/ios/iphonesimulator/Runner.app` to new folder called `Payload`
        - Compress the Payload folder and change the extension to `.ipa`
3. Install the `IPA` file using AltStore or Sideloadly

## Maintenance

### Icon Generation

The following command updates the app icon to the image at `assets/icon.png`

```bash
dart run flutter_launcher_icons
```

### Dependency Validation

The following command checks for unused dependencies:

```bash
dart run dependency_validator
```