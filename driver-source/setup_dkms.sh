#!/usr/bin/env bash
set -euo pipefail

# Setup DKMS for tn40xx so it rebuilds automatically on kernel updates.
# This script copies the driver sources into /usr/src/<name>-<version>,
# registers with DKMS, builds for the current kernel, installs, and loads it.

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

if ! command -v dkms >/dev/null 2>&1; then
  echo "DKMS is not installed. Install dkms first, then re-run this script." >&2
  exit 2
fi

KVER=$(uname -r)
KBUILD="/lib/modules/${KVER}/build"
if [[ ! -d "$KBUILD" ]]; then
  echo "Kernel headers not found at $KBUILD. Install kernel headers for ${KVER}." >&2
  exit 3
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SRC_DIR="$SCRIPT_DIR"
DKMS_NAME=tn40xx
DKMS_VER=$(awk -F= '/^PACKAGE_VERSION/ {gsub(/\"/,"",$2); print $2}' "$SRC_DIR/dkms.conf")
DEST="/usr/src/${DKMS_NAME}-${DKMS_VER}"

echo "Preparing DKMS source at $DEST"
mkdir -p "$DEST"

# Copy sources, excluding build artifacts
rsync -a --delete \
  --exclude '.git/' \
  --exclude '*.o' --exclude '*.ko' --exclude '*.mod' --exclude '*.mod.c' \
  --exclude '.*.cmd' --exclude '.tmp_versions/' --exclude 'modules.order' --exclude 'Module.symvers' \
  "$SRC_DIR/" "$DEST/"

if [[ ! -f "$DEST/x3310fw_0_3_4_0_9445.hdr" && ! -f "$DEST/MV88X3310_phy.h" ]]; then
  echo "Warning: MV88X3310 firmware .hdr not found in $DEST; build may fail." >&2
fi

set -x
dkms remove -m "$DKMS_NAME" -v "$DKMS_VER" --all || true
dkms add -m "$DKMS_NAME" -v "$DKMS_VER"
dkms build -m "$DKMS_NAME" -v "$DKMS_VER" -k "$KVER"
dkms install -m "$DKMS_NAME" -v "$DKMS_VER" -k "$KVER"
set +x

depmod "$KVER" || true

modprobe tn40xx || true
echo "DKMS setup complete. Module info:"
modinfo tn40xx | sed -n '1,80p' || true
