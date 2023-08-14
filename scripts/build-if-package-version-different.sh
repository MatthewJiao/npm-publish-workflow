#!/bin/bash

package_name=$(jq -r '.name' package.json);
local_package_version=$(jq -r '.version' package.json);

latest_version=$(npm view --silent ${package_name} version)

echo "here"
echo $package_name
echo $local_package_version
echo $latest_version

if [ "$local_package_version" != "$latest_version" ]; then yarn lint && yarn build; else :; fi