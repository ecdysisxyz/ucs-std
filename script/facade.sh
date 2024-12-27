#!/bin/bash

# Determine the OS
OS="$(uname -s)"
ARCH="$(uname -m)"

EXECUTABLE=""

case "$OS" in
    Darwin)
        if [ "$ARCH" = "x86_64" ]; then
            EXECUTABLE="facade-macos-x64"
        elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
            EXECUTABLE="facade-macos-arm64"
        else
            echo "Unsupported architecture: $ARCH"
            exit 1
        fi
        ;;
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            EXECUTABLE="facade-linux-x64"
        else
            echo "Unsupported architecture: $ARCH"
            exit 1
        fi
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Run the executable
if [ -x "./etc/facadeBuilder/$EXECUTABLE" ]; then
    "./etc/facadeBuilder/$EXECUTABLE" "$@"
else
    echo "Executable not found or not executable: ./bin/$EXECUTABLE"
    exit 1
fi

