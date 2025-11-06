#!/usr/bin/env bash
set -euo pipefail

# Ensure tn40xx is present after a reboot or system update.
# Use DKMS if available; otherwise build/load from this source tree.

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
KVER=$(uname -r)

is_loaded() {
  lsmod | awk '{print $1}' | grep -qx tn40xx
}

if is_loaded; then
  exit 0
fi

if command -v modprobe >/dev/null 2>&1 && modprobe tn40xx 2>/dev/null; then
  exit 0
fi

if command -v dkms >/dev/null 2>&1; then
  # Try DKMS autoinstall for the current kernel
  dkms autoinstall -k "$KVER" || true
  if modprobe tn40xx 2>/dev/null; then
    exit 0
  fi
fi

# Fall back to local build from source tree
cd "$SCRIPT_DIR"

# Prefer firmware installer if .hdr present
if [[ -f ./x3310fw_0_3_4_0_9445.hdr && -x ./install_mv88x3310.sh ]]; then
  ./install_mv88x3310.sh ./x3310fw_0_3_4_0_9445.hdr || true
fi

# Build and load tn40xx
make MV88X3310=YES || true
modprobe -r tn40xx 2>/dev/null || true
modprobe -r tehuti 2>/dev/null || true
insmod ./tn40xx.ko || true

# Optional: mitigate conflict with in-tree tehuti on next boots
if [[ -d /etc/modprobe.d ]]; then
  echo 'blacklist tehuti' >/etc/modprobe.d/blacklist-tehuti.conf || true
fi
if [[ -d /etc/modules-load.d ]]; then
  echo 'tn40xx' >/etc/modules-load.d/tn40xx.conf || true
fi

exit 0
