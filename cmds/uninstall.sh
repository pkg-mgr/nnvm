#!/bin/bash

# Removes the specified node binary. You must specify a version.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

version=${1:-}
if [ -z "$version" ]; then
  echo "No version provided. Please supply a version number. (ex: nnvm uninstall 8.9.2)"
  exit 1
fi

base_dir="$HOME/.nnvm"
version_dir="$base_dir/$version"

function remove_dir() {
  dir_path=$1
  if [[ $dir_path == $base_dir/* ]]; then
    if [ -d "$dir_path" ]; then
      rm -rf "$dir_path"
      echo "Removed folder: $dir_path"
    fi
  else
    echo "Error: Cannot remove folders outside of $base_dir"
	 exit 1
  fi
}

remove_dir "$version_dir"

# Todo: add messaging if the version doesn't exist
