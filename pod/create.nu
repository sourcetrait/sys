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

    print $ssh_dir
    #ensure_ssh_dir $ssh_dir
}

def err [msg: string]: nothing -> error {
    error make --unspanned $"(ansi red)[sysbox](ansi reset) ($msg)"
}

def 'install self dir' [
    directory: directory
]: nothing -> nothing {
    match $nu.os-info.family {
        'unix' => {||
            ^install -d -o ($PLATFORM.unix.uid) -g ($PLATFORM.unix.gid) -m 700 $directory
        }
        #'windows' => {|| install_windows $owner $group $mode $src $dst $directory }
        _ => {|| err $"unsupported os family: (ansi orange)($nu.os-info.family)(ansi reset)" }
    } 
}

def 'install self file' [
    source: path
    destination: path
]: nothing -> nothing {
    match $nu.os-info.family {
        'unix' => {||
            ^install -T -o ($PLATFORM.unix.uid) ($PLATFORM.unix.gid) -m 700 $source $destination
        }
        #'windows' => {|| install_windows $owner $group $mode $src $dst $directory }
        _ => {|| err $"unsupported os family: (ansi orange)($nu.os-info.family)(ansi reset)" }
    } 
}

def 'install self empty file' [
    destination: path
]: nothing -> nothing {
    match $nu.os-info.family {
        'unix' => {||
            ^install -T -o ($PLATFORM.unix.uid) ($PLATFORM.unix.gid) -m 700 $null_device $destination
        }
        #'windows' => {|| install_windows $owner $group $mode $src $dst $directory }
        _ => {|| err $"unsupported os family: (ansi orange)($nu.os-info.family)(ansi reset)" }
    } 
}

def ensure_ssh_dir [ssh_dir: directory]: nothing -> nothing {
    let config = $ssh_dir | path join 'config'
    let authorized_keys = $ssh_dir | path join 'authorized_keys'
    let pod_dir = $ssh_dir | path join 'local' 'pod'

    if not ($ssh_dir | path exists) {
        install self dir $ssh_dir
    }
    if not ($config | path exists) {
        install self empty file $config
    }
    if not ($authorized_keys | path exists) {
        install self empty file $authorized_keys
    }
    if not ($pod_dir | path exists) {
        install self dir $pod_dir
    }
}
