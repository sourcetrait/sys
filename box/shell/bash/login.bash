#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(realpath "$(dirname "$(readlink "${BASH_SOURCE[0]}")")/../..")"
source "$REPO_DIR/shell/bash/lib.bash"
cd $REPO_DIR

hostname="${1:-}"

usage() {
    echo -e "enters a terminal within a sysbox podman container"
    echo -e "usage: login.bash <hostname>"
    exit 1
}

if [[ -z "$hostname" ]]; then
    usage
fi

podman start "$hostname" 1>/dev/null
exec podman exec -it --user box --workdir /home/box "$hostname" bash
