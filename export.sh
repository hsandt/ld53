#!/usr/bin/env bash

title="Godot Project Bootstrap - Compatibility Renderer"
all_platforms=(windows osx linux web)
godot_bin="godot4.0.2_stable"
godoticon_path="scripts/editor/godoticon"

usage() {
  echo "Export game for Windows, OSX, Linux and Web with specified version.

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
  TARGET                Target platform: 'windows', 'osx', 'linux', 'web' or 'all'
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
  version_folder="$2"
  target="$3"
  replace_icon="$4"

  target_path="Export/$version_folder/$target"

  mkdir -p "Export/$version_folder"
  "$godot_bin" --no-window --export-release "$preset" "$target_path" --verbose

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
      folder="Windows"
      target="${title}.exe"
      # Replace icon scripts are only for Windows executables
      replace_icon=true
      ;;
    linux )
      preset="Linux/X11"
      folder="Linux"
      target="${title}.x86_64"
      replace_icon=false
      ;;
    osx )
      preset="macOS"
      folder="OSX"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        target="${title}.dmg"
      else
        target="${title}.zip"
      fi
      replace_icon=false
      ;;
    web )
      preset="Web"
      folder="Web"
      target="index.html"
      replace_icon=false
      ;;
    * )
      echo "Invalid platform: '$platform'"
      usage
      exit 1
      ;;
  esac

  export_release "$preset" "v$version/$folder" "$target" "$replace_icon"
}

if [[ "$target" == "all" ]]; then
  platforms=("${all_platforms[*]}")
else
  platforms="$target"
fi
for platform in ${platforms[@]}; do
  echo "Exporting for $platform..."
  export_platform_release "$version" "$platform"
done
