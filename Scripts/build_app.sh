#!/bin/zsh
set -euo pipefail

script_dir=${0:A:h}
project_root=${script_dir:h}
app_path="$project_root/dist/ColorPicker.app"
binary_path="$project_root/.build/arm64-apple-macosx/release/ColorPicker"

cd "$project_root"
swift build -c release --arch arm64

if [[ ! -x "$binary_path" ]]; then
  print -u2 "Expected executable was not produced: $binary_path"
  exit 1
fi

rm -rf "$app_path"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
cp "$binary_path" "$app_path/Contents/MacOS/ColorPicker"
cp "$project_root/Resources/Info.plist" "$app_path/Contents/Info.plist"
cp "$project_root/Resources/AppIcon.icns" "$app_path/Contents/Resources/AppIcon.icns"
ditto "$project_root/Resources/en.lproj" "$app_path/Contents/Resources/en.lproj"
ditto "$project_root/Resources/ko.lproj" "$app_path/Contents/Resources/ko.lproj"
usage_description=$( /usr/libexec/PlistBuddy -c 'Print :NSScreenCaptureUsageDescription' "$app_path/Contents/Info.plist" )
if [[ -z "$usage_description" ]]; then
  print -u2 "NSScreenCaptureUsageDescription is required"
  exit 1
fi
codesign --force --sign - "$app_path"
plutil -lint "$app_path/Contents/Info.plist"
plutil -lint "$app_path/Contents/Resources/en.lproj/InfoPlist.strings"
plutil -lint "$app_path/Contents/Resources/ko.lproj/InfoPlist.strings"
codesign --verify --deep --strict --verbose=2 "$app_path"
print "Built $app_path"
