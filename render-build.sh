#!/usr/bin/env bash

# Install Flutter if not already installed
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web support
flutter config --enable-web

# Verify Flutter installation
flutter doctor

# Install dependencies
flutter pub get

# Build Flutter web
flutter build web
