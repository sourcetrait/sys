#!/usr/bin/env bash
set -euo pipefail
echo "[sysbox] user install: begin: box"

export UENV_USR_OF="$HOME/.sys/of"
export RUSTUP_HOME="$UENV_USR_OF/rustup"
export CARGO_HOME="$UENV_USR_OF/cargo"
export PATH="$CARGO_HOME/bin:$PATH"

echo "[sysbox] install rust"
mapfile -t targets < /mnt/dist/list/rust/target.list
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
| sh -s -- -y --no-modify-path --default-toolchain none
rustup set profile complete
rustup toolchain install stable --force
rustup toolchain install nightly --force
rustup target add --toolchain stable "${targets[@]}"
rustup target add --toolchain nightly "${targets[@]}"
rustup default stable

echo "[sysbox] cargo install crates"
mapfile -t crates < /mnt/dist/list/rust/crate.list
for crate in "${crates[@]}"; do
    cargo install --locked "$crate"
done

echo "[sysbox] rust cleanup"
cargo cache --autoclean

echo "[sysbox] user install: done: box"
exit 0
