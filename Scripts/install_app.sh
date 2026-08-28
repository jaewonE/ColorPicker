#!/bin/zsh
set -euo pipefail

script_dir=${0:A:h}
project_root=${script_dir:h}
source_app="$project_root/dist/ColorPicker.app"
destination_app="/Applications/ColorPicker.app"

"$project_root/Scripts/build_app.sh"
if [[ -e "$destination_app" ]]; then
  rm -rf "$destination_app"
fi
ditto "$source_app" "$destination_app"
codesign --verify --deep --strict --verbose=2 "$destination_app"
print "Installed $destination_app"
