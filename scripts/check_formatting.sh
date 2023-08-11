#!/bin/bash

CHANGESET_DIR=".changeset"
ERROR_FOUND=0  

for file in $CHANGESET_DIR/*.md; do
    # Check for package name and semver-bump-type
    if ! (head -n 1 $file | grep -qE '^---$' && head -n 2 $file | tail -n 1 | grep -qE '^".+": (major|minor|patch)$' && head -n 3 $file | tail -n 1 | grep -qE '^---$'); then
        echo "Invalid format in $file (package name and semver-bump-type missing or incorrect)"
        ERROR_FOUND=1
        break  
    fi

    # Check for subheadings
    while IFS= read -r line; do
        if [[ -n $line ]]; then
            if ! echo "$line" | grep -qE '^<.*>.+'; then
                echo "Invalid format in $file (subheading or summary missing or incorrect)"
                ERROR_FOUND=1
                break 2
            fi
        fi
    done < <(tail -n +4 "$file")

    if [[ $ERROR_FOUND -eq 1 ]]; then
        break
    fi
done

if [[ $ERROR_FOUND -eq 1 ]]; then
    exit 1
else
    echo "All changeset files have valid format."
fi
