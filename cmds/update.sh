#!/bin/bash

# Updates nnvm to the latest version. Also updates node package.json / remote version list.

set -e # exit on errors
set -o pipefail # exit on pipe failure
set -u # exit on unset variables

curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/pkg-mgr/nnvm/main/setup.sh | bash
