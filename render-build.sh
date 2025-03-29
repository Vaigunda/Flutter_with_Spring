#!/usr/bin/env bash

# Ensure Flutter is installed
flutter --version

# Enable web support
flutter config --enable-web

# Install dependencies
flutter pub get

# Build Flutter Web
flutter build web --release

# Move build output to Render's public directory
cp -r build/web/* ./public/
