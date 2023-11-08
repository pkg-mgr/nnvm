#!/bin/bash

# Sets the default node version for the current shell session.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.nnvm"
default_version_file="$base_dir/default-version.txt"

default_exists() {
  if [ -f "$default_version_file" ]; then
    default_version=$(head -n 1 "$default_version_file")
    echo "$default_version"
  else
    echo "No default version set." > "$(tty)"
    exit 0
  fi
}

# if no version is provided, report the current version instead
if [ $# -eq 0 ]; then
  default_exists
  exit 0
fi

# since a version is provided here, we should resolve the input
base_dir="$HOME/.nnvm"
cmds_dir="$base_dir/cmds"
version=$("$cmds_dir/resolve_version.sh" "${1:-}")

# Check if the version is already installed
if [ ! -f "$HOME/.nnvm/$version/bin/node" ]; then
  echo "Version $version is not installed. Please install it first. (nnvm install $version)"
  exit 1
fi

# Next, set the new default version:
echo "$version" > "$default_version_file"
echo "Setting default version to $version"
if [ "$NNVM_DEBUG" = "true" ]; then
  echo "DEBUG: Wrote version $version to $default_version_file"
fi
