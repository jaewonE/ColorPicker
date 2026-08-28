#!/bin/zsh
set -euo pipefail

script_dir=${0:A:h}
project_root=${script_dir:h}
version=$( /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$project_root/Resources/Info.plist" )
archive_name="ColorPicker-${version}-macOS-arm64.zip"
archive_path="$project_root/dist/$archive_name"
checksum_path="$archive_path.sha256"

"$project_root/Scripts/build_app.sh"
rm -f "$archive_path" "$checksum_path"
cd "$project_root/dist"
/usr/bin/zip -qry "$archive_name" "ColorPicker.app"
shasum -a 256 "$archive_name" > "$archive_name.sha256"
print "Packaged $archive_path"
