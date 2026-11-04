#!/usr/bin/env nu

const REPO: directory = path self ../..
const NAMES: list<string> = [ fedora ]

export def arg_name []: nothing -> list<string> { $NAMES }

def main [name: string@arg_name]: nothing -> nothing {
    cd $"($REPO)/pod/dist/($name)"
    ^podman build --pull --no-cache -t localhost/syspod/fedora .
}
