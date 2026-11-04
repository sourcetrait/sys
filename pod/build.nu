#!/usr/bin/env nu

const REPO_POD: directory = path self .
const PODS: list<string> = [ fedora ]

# Builds a syspod podman container
def main [pod: directory]: nothing -> nothing {
    if not ($pod in $PODS) {
        error make --unspanned $"(ansi red)[syspod](ansi reset) invalid pod: (ansi yellow)($pod)(ansi reset)"
    }
    
    cd $"($REPO_POD)/($pod)"
    ^podman build --pull --no-cache -t localhost/syspod/($pod) .
}
