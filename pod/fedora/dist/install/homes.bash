#!/usr/bin/env bash
set -euo pipefail

echo "[sysbox] install: homes: begin"

echo "[sysbox] setup home: root"
cp -a /etc/sysbox/skel/uenv/. /root
cp -a /etc/sysbox/skel/uenv-desk/. /root
chmod -R go-rwx /root
chown -R root:root /root

echo "[sysbox] setup home: box"
install -d -o box -g box /home/box
cp -a /etc/sysbox/skel/uenv/. /home/box
cp -a /etc/sysbox/skel/uenv-desk/. /home/box
chmod -R go-rwx /home/box
chown -R box:box /home/box

echo "[sysbox] setup home: super"
install -d -o super -g super /home/super
cp -a /etc/sysbox/skel/uenv/. /home/super
cp -a /etc/sysbox/skel/uenv-desk/. /home/super
chmod -R go-rwx /home/super
chown -R super:super /home/super

echo "[sysbox] setup group home: super-box"
install -d -o root -g root -m 755 /home/group
install -d -o root -g super-box -m 2770 /home/group/super-box
setfacl -d -m u::rwx,g::rwx,o::---,m::rwx /home/group/super-box

echo "[sysbox] cleanup and re-permission"
cd /root
rm -rf /tmp/* /tmp/.*
echo "[sysbox] install: homes: done"
exit 0
