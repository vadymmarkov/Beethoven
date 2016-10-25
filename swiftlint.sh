#!/bin/bash

# Installs the SwiftLint package.

set -e

SWIFTLINT_SOURCE_URL="https://github.com/realm/SwiftLint.git"
SWIFTLINT_SOURCE_PATH="/tmp/SwiftLint"
SWIFTLINT_PKG_PATH="/tmp/SwiftLint.pkg"
SWIFTLINT_PKG_URL="https://github.com/realm/SwiftLint/releases/download/0.11.1/SwiftLint.pkg"

wget --output-document=$SWIFTLINT_PKG_PATH $SWIFTLINT_PKG_URL

if [ -f $SWIFTLINT_PKG_PATH ]; then
    echo "Installing SwiftLint..."
    sudo installer -pkg $SWIFTLINT_PKG_PATH -target /
else
    echo "Failed to install SwiftLint. Compiling from source..." &&
    git clone $SWIFTLINT_SOURCE_URL $SWIFTLINT_SOURCE_PATH &&
    cd $SWIFTLINT_SOURCE_PATH &&
    git submodule update --init --recursive &&
    sudo make install
fi
