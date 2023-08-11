#!/bin/bash

CHANGESET_DIR=".changeset"

for file in $CHANGESET_DIR/*.md; do
    # Check for package name and semver-bump-type
    if ! (head -n 1 $file | grep -qE '^---$' && head -n 2 $file | tail -n 1 | grep -qE '^".+": (major|minor|patch)$'); then
        echo "Invalid format in $file (package name and semver-bump-type missing or incorrect)"
        exit 1
    fi

    # Check for subheadings
    if ! tail -n +4 $file | grep -qE '^\[.*\] .+'; then
        echo "Invalid format in $file (subheading or summary missing or incorrect)"
        exit 1
    fi
done

echo "All changeset files have valid format."


