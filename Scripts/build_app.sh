#!/bin/zsh
set -euo pipefail

script_dir=${0:A:h}
project_root=${script_dir:h}
app_path="$project_root/dist/ColorPicker.app"
binary_path="$project_root/.build/arm64-apple-macosx/release/ColorPicker"
requirements_path="$project_root/Resources/ColorPicker.requirements"

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
codesign --force --sign - \
  --identifier com.jaewone.colorpicker \
  --requirements "$requirements_path" \
  "$app_path"
plutil -lint "$app_path/Contents/Info.plist"
codesign --verify --deep --strict --verbose=2 "$app_path"
print "Built $app_path"
