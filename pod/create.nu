#!/usr/bin/env nu
use std/util null_device

def platform []: nothing -> record<unix: oneof<nothing, record<uid: int, gid: int>>> {
    {
        unix: {
            uid: (^id -u | into int)
            gid: (^id -g | into int)
        }
    }
}

let PLATFORM: record<unix: oneof<nothing, record<uid: int, gid: int>>> = (platform)

# Creates a sysbox podman container
export def main [
    hostname: string  # hostname and name of the container
    --home: oneof<nothing, directory>  # overrides $HOME
]: nothing -> nothing {
    let home = match $home {
        null => $env.HOME
        _ => ($home | path expand)
    }
    let ssh_dir = $home | path join '.ssh'

    check_pod_ssh $ssh_dir $hostname
    ensure_ssh_dir $ssh_dir
    ensure_pod_ssh_dir $ssh_dir $hostname
}

def err [msg: string, help?: string]: nothing -> error {
    mut r = { msg: $"(ansi red)[sysbox](ansi reset) ($msg)" }
    if not ($help | is-empty) {
        $r.help = $help
    }

    error make --unspanned $r
}

def 'install self dir' [
    directory: directory
    --beyond: directory  # explicit permissions for missing components beyond this dir
]: nothing -> nothing {
    if not ($beyond | is-empty) {
        let dirs = between_dirs $beyond $directory
        for dir in $dirs {
            if not ($dir | path exists) {
                install self dir $dir
            }
        }
    }
    
    match $nu.os-info.family {
        'unix' => {
            ^install -d -o ($PLATFORM.unix.uid) -g ($PLATFORM.unix.gid) -m 0700 $directory
        }
        #'windows' => {|| install_windows $owner $group $mode $src $dst $directory }
        _ => {|| err $"unsupported os family: (ansi orange)($nu.os-info.family)(ansi reset)" }
    } 
}

def between_dirs [start: directory, end: directory]: nothing -> list<directory> {
    mut base: directory = $start
    mut paths: list<directory> = []
    for c in ($end | path relative-to $start | path split | drop 1) {
        let d = $base | path join $c
        $paths = ($paths | append $d)
        $base = $d
    }
    
    $paths
}

def 'install self file' [
    source: path
    destination: path
]: nothing -> nothing {
    match $nu.os-info.family {
        'unix' => {
            ^install -T -o ($PLATFORM.unix.uid) -g ($PLATFORM.unix.gid) -m 0700 $source $destination
        }
        #'windows' => {|| install_windows $owner $group $mode $src $dst $directory }
        _ => { err $"unsupported os family: (ansi orange)($nu.os-info.family)(ansi reset)" }
    } 
}

def 'install self empty file' [
    destination: path
]: nothing -> nothing {
    match $nu.os-info.family {
        'unix' => {
            ^install -T -o ($PLATFORM.unix.uid) -g ($PLATFORM.unix.gid) -m 0700 $null_device $destination
        }
        #'windows' => {|| install_windows $owner $group $mode $src $dst $directory }
        _ => { err $"unsupported os family: (ansi orange)($nu.os-info.family)(ansi reset)" }
    } 
}

def check_pod_ssh [ssh_dir: directory, name: string]: nothing -> nothing {
    let pod_dir = $ssh_dir | path join 'pod' $name
    if ($pod_dir | path exists) {
        err $"pod ssh dir exists: (ansi red)($pod_dir)(ansi reset)"
    }

    let config = $ssh_dir | path join 'config'
    if not ($config | path exists) { return }
    let pod_config = ($pod_dir | path join 'config' | path expand)
    let super_name = $"super.($name)"


    let found = open --raw $config | lines
    | each {|s|
        $s | parse --regex '^\s*Host (?<host>\S+)|^\s*Include (?<include>\S+)'
    }
    | flatten
    | where {|x|
        $x.host == $name or $x.host == $super_name or (not ($x.include | is-empty) and ($x.include | path expand) == $pod_config)
    }

    if not ($found | is-empty) {
        if not ($found | get host | where {|x| $x | is-not-empty} | is-empty) {
            err $"ssh hosts exist: (ansi yellow)($config)(ansi reset)" $"hosts: (ansi yellow)($found | get host | to nuon)(ansi reset)"
        } else if not ($found | get include | where {|x| $x | is-not-empty } | is-empty) {
            err $"ssh includes exist: (ansi yellow)($config)(ansi reset)" $"includes: (ansi yellow)($found | get include | to nuon)(ansi reset)"
        }
    }

    return
}

def ensure_ssh_dir [ssh_dir: directory]: nothing -> nothing {
    let config = $ssh_dir | path join 'config'
    let authorized_keys = $ssh_dir | path join 'authorized_keys'

    if not ($ssh_dir | path exists) {
        install self dir $ssh_dir
    }
    if not ($config | path exists) {
        install self empty file $config
    }
    if not ($authorized_keys | path exists) {
        install self empty file $authorized_keys
    }
}
def ensure_pod_ssh_dir [ssh_dir: directory, name: string]: nothing -> nothing {
    ensure_ssh_dir $ssh_dir

    let pod_dir = $ssh_dir | path join 'pod' $name
    if not ($pod_dir | path exists) {
        install self dir $pod_dir --beyond $ssh_dir
    }
}
