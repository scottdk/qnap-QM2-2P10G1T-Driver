#!/bin/bash

# QNAP QM2-2P10G1T Status Checker
# This script checks the status of your TN9710P 10GbE interface

echo "=== QNAP QM2-2P10G1T Status Check ==="
echo

# Check if the card is detected
echo "1. PCI Device Detection:"
if lspci -d 1fc9:4027 >/dev/null 2>&1; then
    echo "✓ TN9710P card detected:"
    lspci -d 1fc9:4027 -v | head -5
else
    echo "✗ TN9710P card not detected"
    exit 1
fi
echo

# Check if driver is loaded
echo "2. Driver Status:"
if lsmod | grep -q tehuti_qnap; then
    echo "✓ tehuti_qnap driver loaded"
    DRIVER_LOADED=true
elif lsmod | grep -q tehuti; then
    echo "⚠ Standard tehuti driver loaded (no TN9710P support)"
    DRIVER_LOADED=false
else
    echo "✗ No Tehuti driver loaded"
    DRIVER_LOADED=false
fi
echo

# Check network interface
echo "3. Network Interface:"
INTERFACE=$(ip link show | grep -B1 "02:" | grep "enp4s0" | cut -d: -f2 | tr -d ' ' | head -1)
if [ -z "$INTERFACE" ]; then
    INTERFACE="enp4s0"  # Default assumption
fi

if ip link show "$INTERFACE" >/dev/null 2>&1; then
    echo "✓ Interface $INTERFACE exists:"
    ip link show "$INTERFACE"
    
    # Check interface status
    if ip link show "$INTERFACE" | grep -q "state UP"; then
        echo "✓ Interface is UP"
        
        # Check carrier
        if ip link show "$INTERFACE" | grep -q "NO-CARRIER"; then
            echo "⚠ No carrier detected (cable not connected or no link)"
        else
            echo "✓ Carrier detected (link established)"
        fi
    else
        echo "⚠ Interface is DOWN"
    fi
else
    echo "✗ Interface $INTERFACE not found"
fi
echo

# Show link speed if available
echo "4. Link Information:"
if command -v ethtool >/dev/null 2>&1 && [ "$DRIVER_LOADED" = true ]; then
    echo "Link details:"
    ethtool "$INTERFACE" 2>/dev/null | grep -E "Speed:|Duplex:|Link detected:" || echo "ethtool information not available"
else
    echo "ethtool not available or driver not loaded"
fi
echo

# Summary
echo "=== Summary ==="
if [ "$DRIVER_LOADED" = true ]; then
    echo "✓ TN9710P driver is working!"
    echo "Configure with: sudo ip addr add <IP>/<NETMASK> dev $INTERFACE"
else
    echo "✗ Driver needs to be installed or reloaded"
    echo "Run: sudo ./install_qnap_driver.sh"
fi