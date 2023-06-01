#!/usr/bin/env bash

# Windows
convert icon_256.png icon_128.png icon_64.png icon_32.png icon_16.png icon.ico

# macOS (no 64)
png2icns icon.icns icon_256.png icon_128.png icon_32.png icon_16.png