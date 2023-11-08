#!/bin/bash

# Runs node commands with auto-node version detection
# First, check for a .nnvmrc file
# Next, check for a current version set via nnvm use
# Finally, check for a default version
# If no version is found, fail with an error message

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.nnvm"
cmd_dir="$base_dir/cmds"
default_version_file="$base_dir/default-version.txt"

# Set NNVM_DEBUG to false if it's not already set:
: "${NNVM_DEBUG:=false}"

pkg_json_path=""
# Look for a project directory (a dir that contains package.json):
# Start with the current directory
dir=$(pwd)
# While we're not at the root directory
while [[ "$dir" != "/" ]]; do
  # If a package.json file exists in the current directory
  if [[ -f "$dir/package.json" ]]; then
    # Set the variable and break the loop
    pkg_json_path="$dir/package.json"
    break
  fi
  # Go up a directory
  dir=$(dirname "$dir")
done

# Resolve the node version to use
nvmrc_file="$dir/.nvmrc"
if [ -z "${nnvm_parent_pid+x}" ]; then
  parent_pid=$PPID
else
  parent_pid=$nnvm_parent_pid
fi
tmp_version_file="/tmp/nnvm_VERSION_$parent_pid"

# If we have an env var set (because this command is forwarded from npm/npx or user is specifying manually), use that version first:
if [ -n "${FORCE_NODE_VERSION-}" ]; then
  node_version="$FORCE_NODE_VERSION"
  if [ "$NNVM_DEBUG" = "true" ]; then
    echo "FORCE_NODE_VERSION is set, using version: $node_version"
  fi
# Else if we found a package.json file and that directory has a .nnvmrc file, use that explicit version:
elif [ -n "$pkg_json_path" ] && [ -f "$nvmrc_file" ]; then
    node_version=$(head -n 1 "$nvmrc_file")
    if [ "$NNVM_DEBUG" = "true" ]; then
      echo "Found .nvmrc file, using version: $node_version"
    fi
# Else, if we have a temp file with a version that matches the current shell PID (set via nnvm use), use that version:
elif [ -f "$tmp_version_file" ]; then
  node_version=$(head -n 1 "$tmp_version_file")
  if [ "$NNVM_DEBUG" = "true" ]; then
    echo "Using version: $node_version"
    echo "DEBUG: from temp file $tmp_version_file"
  fi
# Else fall back to system-wide default version (if it exists):
elif [ -f "$default_version_file" ]; then
  node_version=$(head -n 1 "$default_version_file")
  if [ "$NNVM_DEBUG" = "true" ]; then
    echo "DEBUG: falling back to default version"
    echo "DEBUG: default_version_file: $default_version_file"
  fi
# Else throw an error because we don't know what version to run:
else
  echo "Unable to determine which version of node to use."
  echo "Set a default version with nnvm default <version>"
  echo "Or use a version for the current shell session with nnvm use <version>"
  exit 1
fi

# Now resolve the specified node version into a full semantic version:
node_version=$("$cmd_dir/resolve_version.sh" "$node_version")

if [ ! -f "$HOME/.nnvm/$node_version/bin/node" ]; then
  echo "Version $node_version is not installed. Please install it first. (nnvm install $node_version)"
  exit 1
fi

# Pass all the original arguments to either npm or node or npx
export npm_config_prefix="$base_dir/$node_version/global_packages"
export NNVM_DEBUG
export FORCE_NODE_VERSION="$node_version"
executable_name=$(basename "$0")
node_executable_path="$base_dir/$node_version/bin/$executable_name"
if [ "$NNVM_DEBUG" = "true" ]; then
  echo "node_executable_path: $node_executable_path"
fi
"$node_executable_path" "$@"
