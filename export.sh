#!/usr/bin/env bash

title="POWDER"
all_platforms=(windows macos linux web)
godot_bin="godot4.0.2_stable"
godoticon_path="scripts/editor/godoticon"

usage() {
  echo "Export game for Windows, macOS, Linux and Web with specified version.

Requirements
- current working directory must be project root
- godot4.0.2_stable must be in PATH
- export_presets.cfg file must be at project root (from editor using Project > Export dialog)
- export templates must be installed locally (on Linux, in ~/.local/share/godot/export_templates/VERSION)
CURRENTLY DISABLED until https://github.com/pkowal1982/godoticon/issues/2 is fixed:
- CreateIcon.gd and ReplaceIcon.gd from https://github.com/pkowal1982/godoticon must be in '$godoticon_path'
- custom icons must be at project root as icon_16x16.png icon_32x32.png icon_48x48.png icon_64x64.png icon_128x128.png icon_256x256.png
"

  echo "Usage: export.sh VERSION TARGET

ARGUMENTS
  VERSION               Version number, without the 'v'. Ex: '3.1.2'
  TARGET                Target platform: 'windows', 'macos', 'linux', 'web' or 'all'
"
}

if [[ $# -ne 2 ]]; then
  echo "Wrong number of arguments: found $#, expected 2."
  echo "Passed arguments: $@"
  usage
  exit 1
fi

version=$1
target=$2

if [[ "$target" != "all" ]]; then
  # check if target is valid, i.e. target is in $platforms array
  valid_target=false

  for platform in ${all_platforms[*]}; do
    if [[ "$target" == "$platform" ]]; then
      valid_target=true
      break
    fi
  done
fi

if [[ "$valid_target" == false ]]; then
  echo "Invalid target: '$target'."
  usage
  exit 1
fi

export_release() {
  preset="$1"
  folder="$2"
  target="$3"
  replace_icon="$4"

  target_path="$folder/$target"

  # Remove any existing folder to avoid leftover files if title changed since
  rm -rf "$folder/"
  mkdir -p "$folder"
  "$godot_bin" --no-window --export-release --quiet "$preset" "$target_path"

  # CURRENTLY DISABLED until https://github.com/pkowal1982/godoticon/issues/2 is fixed:
  # if [[ "$replace_icon" == true ]]; then
  #   "$godot_bin" -s "$godoticon_path/CreateIcon.gd" generated_icon.ico icon_16x16.png icon_32x32.png icon_48x48.png icon_64x64.png icon_128x128.png icon_256x256.png
  #   "$godot_bin" -s "$godoticon_path/ReplaceIcon.gd" generated_icon.ico "$target_path"
  # fi
}

export_platform_release() {
  version="$1"
  platform="$2"

  case "$platform" in
    windows )
      preset="Windows Desktop"
      platform_titlecase="Windows"
      target="${title}.exe"
      # Replace icon scripts are only for Windows executables
      replace_icon=true
      ;;
    linux )
      preset="Linux/X11"
      platform_titlecase="Linux"
      target="${title}.x86_64"
      replace_icon=false
      ;;
    macos )
      preset="macOS"
      platform_titlecase="macOS"
      target="${title}.zip"
      replace_icon=false
      ;;
    web )
      preset="Web"
      platform_titlecase="Web"
      target="index.html"
      replace_icon=false
      ;;
    * )
      echo "Invalid platform: '$platform'"
      usage
      exit 1
      ;;
  esac

  version_folder="Export/v$version"
  subfolder="$title v$version - $platform_titlecase"
  folder_path="$version_folder/$title v$version - $platform_titlecase"

  echo "Exporting for $platform..."
  export_release "$preset" "$folder_path" "$target" "$replace_icon"

  # Enter the version folder, which is the parent folder of the platform subfolders
  # This is important to zip subfolders without copying the whole hierarchy from cwd
  # See https://superuser.com/questions/119649/avoid-unwanted-path-in-zip-file/119661#119661
  # It's optional for macOS where we only copy a file
  pushd "$version_folder"

    if [[ "$platform" == "macos" ]]; then
      # For macOS, Godot already zips the .app, so we just copy it to the outside folder
      # and rename it to full name with version and platformer, so all zips are in the
      # same folder with the same naming convention, ready for the next step
      #(copy to Drive and/or upload to itch.io)
      echo "Copying zip to outside folder"
      cp "${subfolder}/${title}.zip" "${subfolder}.zip"
    else
      echo "Zipping..."
      zip_path="${subfolder}.zip"
      # delete existing one to be safe
      rm -f "$zip_path"
      zip -r "$zip_path" "$subfolder"
    fi

  popd
}

if [[ "$target" == "all" ]]; then
  platforms=("${all_platforms[*]}")
else
  platforms="$target"
fi
for platform in ${platforms[@]}; do
  export_platform_release "$version" "$platform"
done
