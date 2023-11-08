#!/bin/bash

# This script serves as the entrypoint for the nnvm command.
# It determines which script the user is trying to run and executes it, passing on all other args.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

# function on_error {
#   local exit_status=$?
#   if [ $exit_status -ne 0 ]; then
#     echo "Error: The script exited with status: $exit_status"
#   fi
# }
# trap on_error EXIT

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
  echo "No arguments provided. Please supply a command. See nnvm help for more details."
  echo ""
  ~/.nnvm/cmds/help.sh
  exit 1
fi

base_dir="$HOME/.nnvm"
cmds_dir="$base_dir/cmds"

# Set NNVM_DEBUG to false if it's not already set:
: "${NNVM_DEBUG:=false}"

# Get the command from the first argument
cmd=${1:-}

# Shift all arguments to the left (original $1 gets lost)
shift

# Check if the script for the command exists
if [ ! -f "$cmds_dir/$cmd.sh" ]; then
  echo "Command not found: $cmd (no file at: $cmds_dir/$cmd.sh)"
  "$cmds_dir/help.sh"
  exit 1
fi

if [ "$NNVM_DEBUG" = "true" ]; then
  echo "DEBUG: Running command: $cmd"
  if [ -z "$*" ]; then
    echo "DEBUG: No args provided"
  else
    echo "DEBUG: Args:"
    echo "$@"
  fi
fi

# Export original PID (needed for use command)
export nnvm_parent_pid=$PPID
export NNVM_DEBUG

# Run the script for the command with all remaining arguments
"$cmds_dir/$cmd.sh" "$@"
