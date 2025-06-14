#!/bin/bash

cd app

flutter build apk --release --target-platform android-arm64 --split-per-abi -v

mv build/app/outputs/flutter-apk/app-arm64-v8a-release.apk build/dist/zero.apk