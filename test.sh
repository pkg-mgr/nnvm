#!/bin/bash

# Integration test suite.

# set -e # exit on errors
# set -o pipefail # exit on pipe failure
# set -u # exit on unset variables

base_dir="$HOME/.nnvm"

error_if_file_exists() {
  if [[ -f $1 ]]; then
    echo "File exists $1"
    exit 1
  fi
}

error_if_dir_exists() {
  if [[ -d $1 ]]; then
    echo "Directory exists $1"
    exit 1
  fi
}

file_should_exist() {
  if [[ ! -f $1 ]]; then
    echo "File does not exist $1"
    exit 1
  fi
}

cmd_should_exist() {
  if ! command -v "$1" &> /dev/null; then
    echo "missing command: $1"
  fi
}

dir_should_exist() {
  if [[ ! -d $1 ]]; then
    echo "Directory does not exist $1"
    exit 1
  fi
}

uninstall_nnvm() {
  echo "y" | ./cmds/nuke.sh
  error_if_dir_exists "$base_dir"
  error_if_file_exists "/usr/local/bin/node"
  error_if_file_exists "/usr/local/bin/nnvm"
  error_if_file_exists "/usr/local/bin/nnvm"
}

check_nnvm_default_version() {
  local expected_version=$1
  default_version_output=$(nnvm default)
  if [[ ! $default_version_output == "$expected_version" ]]; then
    echo "Output '$default_version_output' doesn't match expected '$expected_version'"
    exit 1
  fi
}

check_current_node_version() {
  local expected_version=$1
  node_version=$(node --version)
  if [[ ! $node_version == "v$expected_version" ]]; then
    echo "Current node version $node_version doesn't match expected version $expected_version"
    exit 1
  fi
}

function check_output_contains_str() {
  if [ -z "$2" ]; then
    echo "Error: no string to check for."
    exit 1
  fi
  if [[ "$1" != *"$2"* ]]; then
    echo "Expected string not detected."
    echo "Expected: $1"
    echo "Received: $2"
    exit 1
  fi
}

function on_error {
  exit_status=$?
  if [ $exit_status -eq 0 ]; then
    echo "*** All Tests Passed! ***"
  else
    echo "*** TEST FAILURE ***"
  fi
}

trap on_error EXIT

### Beginning of Tests ###

echo "*** Initial setup, removing any existing install..."
uninstall_nnvm

echo "*** Installing nnvm..."
./setup.sh

echo "Check that base commands exist..."
cmd_should_exist "nnvm"
cmd_should_exist "node"
cmd_should_exist "nnvm"

echo "Test installing a specific version..."
nnvm install 10
file_should_exist "$base_dir/10.24.1/bin/node"
echo "Checking that default version has been set..."
check_nnvm_default_version "10.24.1"
echo "Checking that current node version is correct..."
check_current_node_version "10.24.1"

echo "Test installing a second specific version..."
nnvm install 16.20.2
file_should_exist "$base_dir/16.20.2/bin/node"
echo "Checking that current node version is correct..."
check_current_node_version "16.20.2"

# echo "Test installing a major version..."
# nnvm install 7
# file_should_exist "$base_dir/7.9.5/node"
# check_current_node_version "7.9.5"

echo "Test that nnvm list shows both versions..."
list_output=$(nnvm list 2>&1)
check_output_contains_str "$list_output" "10.24.1"
check_output_contains_str "$list_output" "16.20.2"

echo "Test using a different version..."
nnvm use 10.24.1
check_current_node_version "10.24.1"
nnvm use 16.20.2
check_current_node_version "16.20.2"

echo "Test unusing, should fall back to default version..."
nnvm unuse
check_current_node_version "10.24.1"

echo "Test changing the default version..."
nnvm default 16.20.2
check_current_node_version "16.20.2"

echo "Test uninstalling a version..."
nnvm uninstall 10.24.1
error_if_dir_exists "$base_dir/10.24.1"

echo "Installing an invalid version should not work or delete anything else."
nnvm install 3 2>&1 || true # ignore err
dir_should_exist "$base_dir"
dir_should_exist "$base_dir/16.20.2"

echo "Help command should display text..."
help_output=$(nnvm help 2>&1)
check_output_contains_str "$help_output" "Available commands:"

echo "Check that invalid commands display the help info..."
invalid_cmd_output=$(nnvm invalid_command 2>&1)
check_output_contains_str "$invalid_cmd_output" "Available commands:"

# Temporary, for my own benefit :)
nnvm uninstall 16.20.2
nnvm install 14
nnvm install 18
