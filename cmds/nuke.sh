#!/bin/bash

# Completely removes nnvm from your system.
# This includes all installed versions of node.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

echo "Are you sure you wish to completely uninstall nnvm, config, and installed node binaries? [y/N]"
read -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    base_dir="$HOME/.nnvm"
	 echo Removing "$base_dir"
    rm -rf "$base_dir"
	 echo Removing scripts from /usr/local/bin
	 rm -f /usr/local/bin/node
	 rm -f /usr/local/bin/nnvm
	 echo "Uninstall complete."
else
	 echo "Aborted."
fi
