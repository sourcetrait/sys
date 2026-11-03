#!/usr/bin/env bash
set -euo pipefail
REPO_DIR=$(cd -L -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &>/dev/null && pwd -L)
source "$REPO_DIR/shell/bash/lib.bash"
cd $REPO_DIR

ln -s "$REPO_DIR/shell/bash/build.bash" .
ln -s "$REPO_DIR/shell/bash/create.bash" .
ln -s "$REPO_DIR/shell/bash/login.bash" .
