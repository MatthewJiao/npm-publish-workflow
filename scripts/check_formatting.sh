#!/bin/bash

CHANGESET_DIR="./changeset"

for file in $CHANGESET_DIR/*.md; do
    # Check for package name and semver-bump-type
    head -n 2 $file | grep -qE '---\n".+": (major|minor|patch)'
    if [ $? -ne 0 ]; then
        echo "Invalid format in $file (package name and semver-bump-type missing or incorrect)"
        exit 1
    fi

    # Check for subheadings
    tail -n +4 $file | grep -vE '^\[.*\] .+'
    if [ $? -eq 0 ]; then
        echo "Invalid format in $file (subheading or summary missing or incorrect)"
        exit 1
    fi
done

echo "All changeset files have valid format."
