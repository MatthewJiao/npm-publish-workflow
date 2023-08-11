#!/bin/bash

CHANGESET_DIR=".changeset"
ERROR_FOUND=0  # This is a flag to track if an error is found

for file in $CHANGESET_DIR/*.md; do
    # Check for package name and semver-bump-type
    if ! (head -n 1 $file | grep -qE '^---$' && head -n 2 $file | tail -n 1 | grep -qE '^".+": (major|minor|patch)$'); then
        echo "Invalid format in $file (package name and semver-bump-type missing or incorrect)"
        ERROR_FOUND=1
        break  # Exit the loop if an error is found
    fi

    # Check for subheadings
    # Start by reading from the 4th line onward
    while IFS= read -r line; do
        # Check if line is not empty
        if [[ -n $line ]]; then
            # Check if the line matches the desired format
            if ! echo "$line" | grep -qE '^\[.*\].+'; then
                echo "Invalid format in $file (subheading or summary missing or incorrect)"
                ERROR_FOUND=1
                break 2  # Exit the while loop and the surrounding for loop
            fi
        fi
    done < <(tail -n +4 "$file")

    # If ERROR_FOUND is set, break out of the outer loop as well
    if [[ $ERROR_FOUND -eq 1 ]]; then
        break
    fi
done

# Check if error was found in any file
if [[ $ERROR_FOUND -eq 1 ]]; then
    exit 1
else
    echo "All changeset files have valid format."
fi
