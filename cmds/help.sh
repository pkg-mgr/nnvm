#!/bin/bash

# Displays a list of commands.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

echo ""
echo "Available commands:"
echo "default - displays default version"
echo "default <version> - sets the default (ex: nnvm default 8.9.2)"
echo "help - displays basic usage info (this script)."
echo "install - installs the latest node binary."
echo "install <version> - installs the specified node binary - ex: node install 8.9.2"
echo "list - lists installed node binaries"
echo "list --remote - lists versions available to install"
echo "uninstall <version> - removes the specified node binary - ex: nnvm uninstall 8.9.2"
echo "update - re-installs the latest nnvm scripts as well as node versions list"
echo "use <version> - sets a node version for the current shell session - ex: nnvm use 8.9.2"
echo ""
