# Build Instructions

## Linux
To build a snap package for Linux, first, set up the environment as per the instructions [here](https://flutter.dev/docs/deployment/linux#set-up-the-build-environment). This includes installing `snapcraft` and `multipass`. Then, build the snap with:
```
flutter build linux --release
snapcraft build
```
If there are errors, you may need to do a
```
snapcraft clean telsis-translator-flutter
```
to remove old build files, then try building again.

## Windows
To build for Windows, run:
```
flutter build windows --release
```
which will build the executable `.exe` file and other required files and put them into the `build\windows\runner\Release\` directory. The files in this directory, plus the `data` directory below it, are required to run the application. In addition, `msvcp140.dll`, `vcruntime140.dll`, `vcruntime140_1.dll` from `C:\Windows\System32` are also required for a standalone distribution.

## Android
To build an APK, run:
```
flutter build apk --release
```
which will create an APK in the `build/app/outputs/apk/release directory`.

If an Android device is connected to the computer via USB, you can install the APK by
```
flutter install
```
