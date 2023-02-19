#!/bin/bash


# Build the Flutter app and package into an archive.


# Exit if any command fails
set -e

# Echo all commands for debug purposes
set -x


projectName=telsis_translator_flutter

archiveName=telsis-translator-flutter_0.2.1.tar
baseDir=$(pwd)


# ----------------------------- Build Flutter app ---------------------------- #


flutter pub get
flutter build linux

cd build/linux/x64/release/bundle || exit
tar -cavf $archiveName ./*
mv $archiveName "$baseDir"/
cd "$baseDir"
tar -uavf $archiveName packaging/linux/*
gzip $archiveName
