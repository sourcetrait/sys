
cfg() {
    local name
    name="${1:?name is required}"
    local cfgfile="$REPO_DIR/shell/cfg/$name"
    if [[ ! -f "$cfgfile" ]]; then
        echo -e "error: config not found: $cfgfile"
        exit 1
    fi

    cat "$cfgfile"
}

next_port() {
    local port
    port="${1:?port is required}"
    while ss -tulpn | grep -q ":${port} ";
        do ((port++));
    done;

    echo $port
}
