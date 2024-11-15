#!/bin/bash

# Function to recursively delete build directories and sdkconfig files
function delete_build_dirs_and_files() {
    for file in "$1"/*
    do
        if [ -d "$file" ]; then
            # Delete "build" directories
            if [ "$(basename "$file")" == "build" ] || [ "$(basename "$file")" == "managed_components" ]; then
                echo "Removing directory: $file"
                rm -rf "$file"
            else
                delete_build_dirs_and_files "$file"
            fi
        elif [ -f "$file" ]; then
            # Delete "sdkconfig" files
            if [ "$(basename "$file")" == "sdkconfig" ]; then
                echo "Removing file: $file"
                rm -f "$file"
            fi
        fi
    done
}

# Check if input directory is provided
if [ $# -eq 0 ]; then
    echo "Usage: ./delete_build_sdkconfig.sh <directory>"
    exit 1
fi

# Check if input directory exists
if [ ! -d "$1" ]; then
    echo "Invalid directory: $1"
    exit 1
fi

# Start from the input directory
delete_build_dirs_and_files "$1"

echo "Deletion complete."
