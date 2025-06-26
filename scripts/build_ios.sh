#!/bin/zsh

cd app

rm -rf build/ios/Payload

mkdir -p build/dist
mkdir -p build/ios/Payqload

flutter build ios --release --no-codesign

cp -r build/ios/iphoneos/Runner.app build/ios/Payload

cd build/ios

zip -r ../dist/zero.ipa ./Payload

cd ../..

echo "\033[32mOutput: $(pwd)/build/dist/zero.ipa"
