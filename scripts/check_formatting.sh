#!/bin/bash

CHANGESET_DIR=".changeset"

for file in $CHANGESET_DIR/*.md; do
    # Check for package name and semver-bump-type
    if ! (head -n 1 $file | grep -qE '^---$' && head -n 2 $file | tail -n 1 | grep -qE '^".+": (major|minor|patch)$'); then
        echo "Invalid format in $file (package name and semver-bump-type missing or incorrect)"
        exit 1
    fi

    # Check for subheadings
    # Check for subheadings, filtering out empty lines
    # Start by reading from the 4th line onward
    tail -n +4 $file | while IFS= read -r line; do
        # Check if line is not empty
        if [[ -n $line ]]; then
            # Check if the line matches the desired format
            if ! echo "$line" | grep -qE '^\[.*\].+'; then
                echo "Invalid format in $file (subheading or summary missing or incorrect)"
                exit 1
            fi
        fi
    done

done

echo "All changeset files have valid format."


