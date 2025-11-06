#!/usr/bin/env bash
set -euo pipefail

# QNAP QM2-2P10G1T Status Check Script
# Displays current status of the driver and network interface

echo "=== QNAP QM2-2P10G1T Driver Status ==="
echo

# Check if card is present
echo "🔍 Hardware Detection:"
if lspci | grep -q "1fc9:4027"; then
    echo "✅ QNAP QM2-2P10G1T found:"
    lspci | grep "1fc9:4027"
else
    echo "❌ QNAP QM2-2P10G1T (1fc9:4027) not found in PCI devices"
    echo "Available Tehuti devices:"
    lspci | grep -i tehuti || echo "  None found"
fi
echo

# Check driver status  
echo "🔧 Driver Status:"
if lsmod | grep -q "tn40xx"; then
    echo "✅ tn40xx driver loaded:"
    lsmod | grep tn40xx
elif lsmod | grep -q "tehuti"; then
    echo "⚠️  tehuti driver loaded (should use tn40xx instead):"
    lsmod | grep tehuti
else
    echo "❌ No tn40xx or tehuti driver loaded"
    echo "All loaded network drivers:"
    lsmod | grep -E "(net|eth|tn40)" | head -5 | sed 's/^/  /' || echo "  None found"
fi
echo

# Check network interfaces
echo "🌐 Network Interfaces:"
echo "All network interfaces:"
ip -o link show | awk -F': ' '{printf "  %s -> %s\n", $2, $3}'

echo
# Look for likely tn40xx interfaces
if ip link show | grep -E "(enp4s0|tn40)" >/dev/null; then
    echo "✅ Likely tn40xx interfaces found:"
    for iface in $(ip link show | grep -E "(enp4s0|eth[0-9]+)" | cut -d: -f2 | tr -d ' '); do
        echo "  Interface: $iface"
        ip addr show "$iface" 2>/dev/null | head -3 | sed 's/^/    /'
        if command -v ethtool >/dev/null && [[ $EUID -eq 0 ]]; then
            echo "    Link: $(ethtool "$iface" 2>/dev/null | grep "Link detected" | awk '{print $3}')"
            echo "    Speed: $(ethtool "$iface" 2>/dev/null | grep "Speed" | awk '{print $2}')"
        elif [[ $EUID -ne 0 ]]; then
            echo "    (Run as root for link/speed info)"
        fi
        echo
    done
else
    echo "⚠️  No obvious tn40xx interfaces found"
fi

# Check kernel messages for recent tn40xx activity
echo "📋 Recent Kernel Messages (tn40xx):"
if dmesg | grep -i tn40 | tail -5 >/dev/null 2>&1; then
    dmesg | grep -i tn40 | tail -5 | sed 's/^/  /'
else
    echo "  No recent tn40xx messages found"
fi
echo

# Recommendations
echo "🔧 Recommendations:"
if ! lsmod | grep -q "tn40xx"; then
    echo "  1. Install driver: sudo ./install.sh"
elif ip link show | grep -q "NO-CARRIER"; then
    echo "  1. Check cable connection"
    echo "  2. Verify peer device is configured"
    echo "  3. Try: sudo ethtool <interface> for details"
else
    echo "  ✅ Driver appears to be working correctly!"
    echo "  1. Configure IP: sudo ip addr add YOUR_IP/24 dev <interface>"
    echo "  2. Test connectivity: ping PEER_IP"
fi

echo
echo "=== Status Check Complete ==="