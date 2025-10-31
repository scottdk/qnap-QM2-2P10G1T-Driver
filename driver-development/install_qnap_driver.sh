#!/bin/bash

# QNAP QM2-2P10G1T TN9710P Driver Installation Script
# This script installs a modified Tehuti driver that supports the TN9710P 10GbE NIC
# 
# Usage: sudo ./install_qnap_driver.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRIVER_NAME="tehuti_qnap"
DEVICE_ID="1fc9:4027"

echo "=== QNAP QM2-2P10G1T TN9710P Driver Installation ==="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Check if kernel headers are installed
if [ ! -d "/lib/modules/$(uname -r)/build" ]; then
    echo "Error: Kernel headers not found. Please install kernel headers first."
    exit 1
fi

echo "Building driver..."
cd "$SCRIPT_DIR"
make clean && make

echo "Unloading existing drivers..."
rmmod tehuti_qnap 2>/dev/null || true
rmmod tehuti 2>/dev/null || true

echo "Installing driver..."
insmod ${DRIVER_NAME}.ko

echo "Configuring interface..."
# Wait a moment for the interface to appear
sleep 2

# Find the interface name (should be enp4s0 for device at 04:00.0)
INTERFACE=$(ip link show | grep -A1 "link/ether 00:00:00:00:00:00" | head -1 | cut -d: -f2 | tr -d ' ')

if [ -z "$INTERFACE" ]; then
    echo "Warning: Interface with zero MAC address not found. Driver may have automatically loaded correctly."
    INTERFACE="enp4s0"  # Assume default name
fi

echo "Setting MAC address for interface $INTERFACE..."
# Set a locally administered MAC address (02: prefix makes it locally administered)
ip link set $INTERFACE address 02:qn:ap:10:gb:$(printf '%02x' $((RANDOM % 256)))

echo "Bringing up interface..."
ip link set $INTERFACE up

echo ""
echo "=== Installation Complete ==="
echo "Interface: $INTERFACE"
echo "Status: $(ip link show $INTERFACE | grep -o '<[^>]*>')"
echo ""
echo "Your 10GbE interface is now available!"
echo "You can configure it with an IP address using:"
echo "  sudo ip addr add 192.168.1.100/24 dev $INTERFACE  # Example"
echo ""
echo "Note: This driver will be lost after system updates."
echo "Re-run this script after any TrueNAS system update."