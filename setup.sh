#!/bin/bash

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

base_dir="$HOME/.nnvm"
cmds_dir="$base_dir/cmds"
cmd_list="cmd default help install list nuke run uninstall unuse update update_versions use resolve_version"
NUKE_node=${NUKE_node:-0}

ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "Created directory $1"
  fi
}

if [ "$NUKE_node" -eq 1 ]; then
  echo Optional node uninstall requested, removing any existing node installations...
  while true; do
    if node_path=$(which node 2>/dev/null); then
      echo "Deleting $node_path"
      rm "$node_path"
    else
      echo "node not found"
      break
    fi
  done
fi

# Detect setup method, local or github:
if [[ -t 0 ]] && [[ -d "cmds" ]]; then
  # if standard input is a terminal and the cmds dir exists, use local install
  echo "Performing local install."
  file_source="local"
else
  # likely invoked via curl so default to the github download method
  file_source="github"
fi

# ensure the base dir exists:
ensure_dir "$base_dir"

# clear out cmds dir, if it exists:
if [ -d "$cmds_dir" ]; then
  rm -rf "$cmds_dir" > /dev/null 2>&1
fi
ensure_dir "$cmds_dir"

# copy specific nnvm command scripts to local $cmds_dir:
for cmd_name in $cmd_list
do
  file_name="$cmd_name.sh"
  if [ "$file_source" = "local" ]; then
    echo "Copying file from local: ./cmds/$file_name"
    cp "./cmds/$file_name" "$cmds_dir/$file_name"
    elif [ "$file_source" = "github" ]; then
    # download the file:
    echo "Downloading: https://raw.githubusercontent.com/pkg-mgr/nnvm/main/cmds/$file_name"
    # disable cache, fail on 404, silence progress (but not errors) and save locally:
    curl -H 'Cache-Control: no-cache' -fsS -o "$cmds_dir/$file_name" "https://raw.githubusercontent.com/pkg-mgr/nnvm/main/cmds/$file_name"
  else
    echo "Unknown file source."
    exit 1
  fi
  # make it executable:
  chmod +x "$cmds_dir/$file_name"
done

if [ "$file_source" = "local" ]; then
  current_dir=$(dirname "$0")
  "$current_dir/cmds/update_versions.sh"
else
 "$base_dir/cmds/update_versions.sh"
fi

echo "Installed nnvm cmds: $cmd_list"

echo "Installing scripts in bin folder."
cp "$cmds_dir/cmd.sh" "/usr/local/bin/nnvm"
cp "$cmds_dir/run.sh" "/usr/local/bin/node"
cp "$cmds_dir/run.sh" "/usr/local/bin/npm"
cp "$cmds_dir/run.sh" "/usr/local/bin/npx"

nnvm update_versions

echo Setup completed.
