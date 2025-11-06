#!/usr/bin/env bash
set -euo pipefail

# Installer for tn40xx driver with MV88X3310 PHY support on TrueNAS SCALE/Linux
# Usage: ./install_mv88x3310.sh [/path/to/x3310fw_*.hdr]
# If no argument is provided, the script searches current dir and ./firmware for a matching .hdr.

HERE=$(cd "$(dirname "$0")" && pwd)
cd "$HERE"

# Locate firmware .hdr
HDR_FILE="${1:-}"
if [[ -z "${HDR_FILE}" ]]; then
  HDR_FILE=$(ls -1 x3310fw_*.hdr 2>/dev/null | head -n1 || true)
  if [[ -z "${HDR_FILE}" && -d firmware ]]; then
    HDR_FILE=$(ls -1 firmware/x3310fw_*.hdr 2>/dev/null | head -n1 || true)
  fi
fi

if [[ -z "${HDR_FILE}" ]]; then
  echo "ERROR: MV88X3310 firmware .hdr not found."
  echo "- Please download a file like: x3310fw_0_3_4_0_9445.hdr"
  echo "- Place it in: $HERE or $HERE/firmware"
  echo "- Then re-run: $0"
  exit 1
fi

if [[ ! -f "${HDR_FILE}" ]]; then
  echo "ERROR: Firmware file not found: ${HDR_FILE}" >&2
  exit 1
fi

echo "Using firmware: ${HDR_FILE}"

# Generate header from firmware (.hdr -> MV88X3310_phy.h)
if [[ ! -x ./mvidtoh.sh ]]; then
  echo "ERROR: mvidtoh.sh not found or not executable in $HERE" >&2
  exit 1
fi
./mvidtoh.sh "${HDR_FILE}" MV88X3310 MV88X3310_phy.h

# Build the driver with MV88X3310 support
make clean >/dev/null 2>&1 || true
make MV88X3310=YES

# Unload potential conflicting modules
sudo rmmod tn40xx 2>/dev/null || true
sudo rmmod tehuti 2>/dev/null || true

# Load the new module
sudo insmod ./tn40xx.ko

echo
echo "dmesg (last 20 lines):"
sudo dmesg | tail -20

echo
echo "Interfaces (post-load):"
ip -o link show | awk -F': ' '{print NR": "$2" -> "$3}'

echo
echo "If your interface was created, bring it up like:"
echo "  sudo ip link set <iface> up"
echo "  sudo ip addr add 10.0.11.1/24 dev <iface>"
echo "Then test: ping -c 3 10.0.11.2"
