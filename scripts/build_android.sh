#!/bin/bash

cd app

mkdir -p build/dist/

flutter build apk --release --target-platform android-arm64 --split-per-abi

mv build/app/outputs/flutter-apk/app-arm64-v8a-release.apk build/dist/zero.apk