#!/bin/bash

dir=".changeset"

process_files() {
  local package_name=$1
  local bump_type=$2

  local output_file="${dir}/formatted-${package_name}-${bump_type}.md"
  tmp_dir=$(mktemp -d)
  tmp_output_file=$(mktemp)

  # Process files by package name and bump type
  find $dir -name '*.md' | while read file; do
    if grep -q "\"$package_name\": $bump_type" $file; then
      # Package name and bump type
      package_info="\"${package_name}\": ${bump_type}"

      # Check if the package information is already written to the file
      if ! grep -q -- "$package_info" $tmp_output_file; then
        echo -e "---\n$package_info\n---\n" >> $tmp_output_file
      fi

      sed -n -e '/^---$/,/^---$/!p' $file | tail -n +2 | while read -r line; do
        subheading=$(echo $line | awk -F '[][]' '{print $2}')
        summary=$(echo $line | cut -d ']' -f 2-)
        echo "- $summary" >> "${tmp_dir}/${subheading}.txt"
      done

      ls -l $file
      chmod u+w $file
      rm $file # Deleting the processed file
    fi
  done

  # Print the collected subheadings and summaries
  if [ -s $tmp_output_file ]; then
    for subheading_file in ${tmp_dir}/*.txt; do
      subheading=$(basename "$subheading_file" .txt)
      echo -e "\n**$subheading**" >> $tmp_output_file
      cat "$subheading_file" >> $tmp_output_file
    done
    cat $tmp_output_file > $output_file
    echo "Changesets combined into $output_file!"
  fi

  # Remove temporary directory and file
  rm -r "$tmp_dir"
  rm "$tmp_output_file"
}

# Process files by package name and bump type
packages=("mj-publish-workflow-test-utils" "mj-publish-workflow-test-math")
semver_types=("major" "minor" "patch")

for package in "${packages[@]}"; do
  for semver_type in "${semver_types[@]}"; do
    process_files "$package" "$semver_type"
  done
done