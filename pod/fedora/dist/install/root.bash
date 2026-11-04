#!/usr/bin/env bash
set -euo pipefail

echo "[sysbox] install: root: begin"

echo "[sysbox] copy filesystem"
tar -C /mnt/dist/fs --owner=0 --group=0 --mode=u=rwX,go=rX -cf - . \
| tar -C / --no-overwrite-dir -xf -

echo "[sysbox] create skels"
while IFS= read -r dir || [[ -n "$dir" ]]; do
    [[ -n "$dir" ]] || continue
    mkdir -p -- "/etc/sysbox/skel/uenv/$dir"
done < /mnt/dist/list/dir/uenv.list

while IFS= read -r dir || [[ -n "$dir" ]]; do
    [[ -n "$dir" ]] || continue
    mkdir -p -- "/etc/sysbox/skel/uenv-desk/$dir"
done < /mnt/dist/list/dir/uenv/desk.list

echo "[sysbox] install coprs"
mapfile -t coprs < /mnt/dist/list/copr.list

for copr in "${coprs[@]}"; do
    dnf -y copr enable "$copr"
done

echo "[sysbox] install packages"
mapfile -t packages < /mnt/dist/list/package.list
dnf -y install "${packages[@]}"

echo "[sysbox] update"
dnf -y upgrade

echo "[sysbox] restore package capabilities"
rpm --restore shadow-utils

echo "[sysbox] clean"
dnf clean all

echo "[sysbox] version-lock specific packages"
dnf versionlock add nushell

echo "[sysbox] disable optional services"
systemctl disable --now nginx.service

echo "[sysbox] permission for logins"
chmod 640 /etc/shadow

echo "[sysbox] create user: box ; general usage (no sudo)"
useradd -M -d /home/box -s /usr/bin/nu box
echo 'box:box' | chpasswd

echo "[sysbox] create user: super ; administrative usage (sudo via wheel)"
useradd -M -d /home/super -s /usr/bin/fish super
echo 'super:super' | chpasswd

echo "[sysbox] create group: sshusr ; ssh logins restricted to this group"
groupadd sshusr
echo "[sysbox] create group: super-box ; shared files between super/box at /home/group/super-box"
groupadd super-box
usermod -aG super-box,sshusr box
usermod -aG super-box,sshusr,wheel super

echo "[sysbox] final cleanup and re-permission"
cd /root
rm -rf /tmp/* /tmp/.*
echo "[sysbox] install: root: done"
exit 0
