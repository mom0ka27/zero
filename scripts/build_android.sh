#!/bin/zsh

cd app

flutter build apk --release --target-platform android-arm64 --split-per-abi -v

mv app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk app/build/dist/zero.apk