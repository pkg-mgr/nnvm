#!/bin/bash

# Checks for single-digit major inputs and returns full version numbers

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

find_version() {
  local major_version=$1
  # Read the file and find the line:
  resolved_major=$(grep "^v$major_version\." "$HOME/.nnvm/versions.txt" | grep "^v[0-9\.-]*$" | tail -n 1 | cut -c 2-)
  # Return the result:
  echo "$resolved_major"
}

if [[ -z "${1:-}" ]]; then
    echo "Error in resolve_version.sh - No version specified!"
    exit 1
fi

# check if exact/semantic version is specified
if [[ $1 =~ ^v?[0-9]+\.[0-9]+\.[0-9]+([-.\w]*)$ ]]; then
  # matches `6.32.4` or `v6.32.0` or `7.0.0-rc.0`
  # remove the leading "v" if it exists:
  echo "${1#v}"
  exit 0
fi

version=$1

# next, check if version is lts:
if [[ $version == lts/* ]]; then
  if [ "$version" == "lts/iron" ]; then
    version="20"
    elif [ "$version" == "lts/hydrogen" ]; then
    version="18"
    elif [ "$version" == "lts/gallium" ]; then
    version="16"
    elif [ "$version" == "lts/fermium" ]; then
    version="14"
    elif [ "$version" == "lts/erbium" ]; then
    version="12"
    elif [ "$version" == "lts/dubnium" ]; then
    version="10"
    elif [ "$version" == "lts/carbon" ]; then
    version="8"
    elif [ "$version" == "lts/boron" ]; then
    version="6"
    elif [ "$version" == "lts/argon" ]; then
    version="4"
    else
    echo "Error in resolve_version.sh - Invalid lts version specified!"
    exit 1
  fi
fi

# checks to see if input is a single positive major version integer:
if [[ $version =~ ^[0-9]{1,2}$ ]] && ((version > 0)); then
  # Major version specified
  version=$(find_version "$version")
  echo "$version"
  exit 0
else
  echo "
Invalid version format.
Enter a semantic version, a major version, or an lts codename.
Examples:
  18.14.3
  14
  lts/hydrogen
" > "$(tty)"
  exit 1
fi
