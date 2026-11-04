#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(realpath "$(dirname "$(readlink "${BASH_SOURCE[0]}")")/../..")"
source "$REPO_DIR/shell/bash/lib.bash"
cd $REPO_DIR

boxhost="${1:-}"

usage() {
    echo -e "creates a sysbox podman container"
    echo -e "usage: create.bash <hostname>"
    exit 1
}

ssh_config_exists() {
    local host
    host=${1:?hostname is required}

    awk -v name="$host" '
        tolower($1) == "host" {
            for (i = 2; i <= NF && $i !~ /^#/; i++)
                if ($i == name) found = 1
        }
        END { exit !found }
    ' ~/.ssh/config
}

if [[ -z "$boxhost" ]]; then
    usage
fi

if [[ ! -f "$HOME/.ssh/config" ]]; then
    mkdir -p "$HOME/.ssh"
    touch "$HOME/.ssh/config"
    chmod -R go-rwx "$HOME/.ssh"
fi

pod_dir="$HOME/.ssh/local/pod/$boxhost"
key_dir="$pod_dir/key"
config_file="$pod_dir/$boxhost.config"
box_key="$key_dir/id_box_$boxhost"
box_pubkey="$box_key.pub"
super_key="$key_dir/id_super_$boxhost"
super_pubkey="$super_key.pub"

# don't overwrite config file
if [[ -f "$config_file" ]]; then
	echo -e "[sysbox] error: ssh config already exists: $config_file"
	exit 1
fi
# don't overwrite keys
if [[ -f "$box_key" || -f "$super_key" ]]; then
	echo -e "[sysbox] error: ssh keys already exist: $key_dir"
	exit 1
fi
# don't overwrite host configs
if ssh_config_exists "$boxhost" || ssh_config_exists "super.$boxhost"; then
	echo -e "[sysbox] error: ssh config hosts already exist: ~/.ssh/config"
	exit 1
fi

mkdir -p "$key_dir"

echo "[sysbox] creating ssh keys for users: box and super"
mkdir -p "$key_dir"
ssh-keygen -t ed25519 -C "box@${boxhost}" -f "$box_key"
ssh-keygen -t ed25519 -C "super@${boxhost}" -f "$super_key"
chmod -R go-rwx "$HOME/.ssh"

home_volume="${boxhost}-home"
box_cache_volume="${boxhost}-box-cache"
box_tmp_volume="${boxhost}-box-tmp"
super_cache_volume="${boxhost}-super-cache"
super_tmp_volume="${boxhost}-super-tmp"
ssh_port=$(next_port 21501)

echo "[sysbox] creating container"
podman create --name $boxhost --hostname $boxhost \
 --systemd=always \
 -p $ssh_port:22 \
 --volume $home_volume:/home \
 --volume $box_cache_volume:/home/box/.sys/cache \
 --volume $box_tmp_volume:/home/box/tmp \
 --volume $super_cache_volume:/home/super/.sys/cache \
 --volume $super_tmp_volume:/home/super/tmp \
 "$(cfg image)"

echo "[sysbox] starting container"
podman start $boxhost 1>/dev/null

echo "[sysbox] copying ssh keys"
podman cp "$box_pubkey" ${boxhost}:/home/box/.ssh/authorized_keys
podman exec -u root $boxhost chmod 600 /home/box/.ssh/authorized_keys
podman exec -u root $boxhost chown box:box /home/box/.ssh/authorized_keys

podman cp "$super_pubkey" ${boxhost}:/home/super/.ssh/authorized_keys
podman exec -u root $boxhost chmod 600 /home/super/.ssh/authorized_keys
podman exec -u root $boxhost chown super:super /home/super/.ssh/authorized_keys

echo "[sysbox] setting acls: /home/group/super-box"
podman exec -u root $boxhost setfacl -d -m u::rwx,g::rwx,o::---,m::rwx /home/group/super-box

echo "[sysbox] stopping container"
podman stop $boxhost

echo "[sysbox] configuring ssh hosts for container: $boxhost and super.$boxhost"

cat > "$config_file" <<EOF
Host $boxhost
  Hostname localhost
  Port $ssh_port
  User box
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/key/pod/$boxhost/id_box
Host super.$boxhost
  Hostname localhost
  Port $ssh_port
  User super
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/key/pod/$boxhost/id_super
EOF

include_ssh_config() {
    local config_file padding='' last_line
    config_file=${1:?config_file is required}

    IFS= read -r last_line < <(tail -n 1 -- "$HOME/.ssh/config") || padding=$'\n'

    if [[ -z "$last_line" ]]; then
        padding=''
    elif [[ ! ${last_line,,} =~ ^[[:blank:]]*include([[:blank:]=]|$) ]]; then
        padding+=$'\n'
    fi

    printf '%sInclude "%s"\n' "$padding" "$config_file" >> "$HOME/.ssh/config"
}

include_ssh_config "$config_file"

echo "[sysbox] refreshing known hosts"
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:$ssh_port"

echo "[sysbox] instructions:"
echo "[sysbox] start:  podman start $boxhost"
echo "[sysbox] stop:   podman stop $boxhost"
echo "[sysbox] ssh:    ssh $boxhost"
echo "[sysbox] admin:  ssh super.$boxhost"
echo "[sysbox] done"

