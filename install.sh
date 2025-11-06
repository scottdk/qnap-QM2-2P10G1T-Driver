#!/usr/bin/env bash
set -euo pipefail

# QNAP QM2-2P10G1T Quick Setup Script
# This script installs the tn40xx driver with MV88X3310 PHY firmware support

echo "=== QNAP QM2-2P10G1T 10GbE Driver Setup ==="
echo

# Check if running as root for modprobe operations
if [[ $EUID -ne 0 ]]; then
   echo "This script needs to be run as root for driver installation."
   echo "Usage: sudo $0"
   exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRIVER_DIR="$SCRIPT_DIR/driver-source"

# Check if driver-source exists
if [[ ! -d "$DRIVER_DIR" ]]; then
    echo "Error: driver-source directory not found at $DRIVER_DIR"
    echo "Please ensure you're running this from the project root directory."
    exit 1
fi

echo "Driver source directory: $DRIVER_DIR"

# Check for required files
if [[ ! -f "$DRIVER_DIR/install_mv88x3310.sh" ]]; then
    echo "Error: install_mv88x3310.sh not found in $DRIVER_DIR"
    exit 1
fi

if [[ ! -f "$DRIVER_DIR/x3310fw_0_3_4_0_9445.hdr" ]]; then
    echo "Error: MV88X3310 firmware file not found in $DRIVER_DIR"
    exit 1
fi

echo "✅ All required files found"
echo

# Check if QNAP card is present
if ! lspci | grep -q "1fc9:4027"; then
    echo "⚠️  Warning: QNAP QM2-2P10G1T (1fc9:4027) not found in PCI devices"
    echo "Continuing anyway in case device ID differs..."
    echo
fi

# Run the installation
echo "🚀 Starting tn40xx driver installation with MV88X3310 PHY firmware..."
cd "$DRIVER_DIR"

if ./install_mv88x3310.sh; then
    echo
    echo "✅ Installation completed successfully!"
    echo
    echo "=== Driver Status ==="
    if lsmod | grep -q tn40xx; then
        echo "✅ tn40xx driver loaded"
        lsmod | grep tn40xx
    else
        echo "❌ tn40xx driver not loaded"
    fi
    
    echo
    echo "=== Network Interfaces ==="
    if ip link show | grep -q "enp4s0\|tn40"; then
        echo "✅ Network interface found:"
        ip link show | grep -E "(enp4s0|tn40)" || echo "Interface detection may have different name"
    else
        echo "⚠️  No obvious tn40xx interface found. Check 'ip link show' for new interfaces."
    fi
    
    echo
    echo "=== Next Steps ==="
    echo "1. Find your interface: ip link show"
    echo "2. Configure IP: sudo ip addr add YOUR_IP/24 dev INTERFACE_NAME"
    echo "3. Bring up link: sudo ip link set INTERFACE_NAME up"
    echo "4. Check status: sudo ethtool INTERFACE_NAME"
    echo
    echo "Example:"
    echo "  sudo ip link set enp4s0 up"
    echo "  sudo ip addr add 10.0.11.1/24 dev enp4s0"
    echo "  sudo ethtool enp4s0"
    echo
else
    echo "❌ Installation failed. Check the error messages above."
    echo "Try manual installation:"
    echo "  cd $DRIVER_DIR"
    echo "  sudo ./install_mv88x3310.sh"
    exit 1
fi