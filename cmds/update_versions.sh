#!/bin/bash

# Gets a list of all supported node versions from the nodejs.org/dist page

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

current_dir=$(dirname "$0")

echo Updating available versions...

# download the list of versions
# strip out non-standard versions
# strip out non-version prefix
# sort by version number
# save to directory above the current script dir
# (this way it works in repo and installed location)
curl "https://nodejs.org/dist/" \
  | grep -Eo '<a href="v[1-9][0-9]*\.[0-9]+\.[0-9]+/' \
  | sed 's/^<a href="//;s/\/$//' \
  | sort -V \
  > "$current_dir/../versions.txt"
