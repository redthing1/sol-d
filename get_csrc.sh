#!/usr/bin/env bash

###
### DEPENDENCY LIBRARY BUILDER SCRIPT
### redthing1
###

set -e

HOST="sol-d"
LIB_NAME="sol"
SOURCETREE_URL="https://github.com/redthing1/sol.git"
SOURCETREE_DIR="sol_c"
SOURCETREE_BRANCH="main"

PACKAGE_DIR=$(dirname "$0")
cd "$PACKAGE_DIR"
pushd .

echo "[$HOST] getting $LIB_NAME library..."

# delete $SOURCETREE_DIR to force re-fetch source
if [ -d $SOURCETREE_DIR ]; then
    # echo "[$HOST] source folder already exists, using it."
    true
else
    echo "[$HOST] getting c source of $LIB_NAME"
    # git clone $SOURCETREE_URL $SOURCETREE_DIR
    git clone --depth 1 --branch $SOURCETREE_BRANCH $SOURCETREE_URL $SOURCETREE_DIR
fi

popd
