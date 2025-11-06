#!/usr/bin/env bash
# Quick manual loader for tn40xx driver after reboot
# Usage: sudo ./load_tn40xx_manual.sh

cd "$(dirname "$0")"

echo "Loading tn40xx driver..."
sudo rmmod tn40xx tehuti_qnap tehuti 2>/dev/null || true
sudo insmod driver-source/tn40xx.ko
sleep 2
sudo ip link set enp4s0 up
sudo ip addr add 10.0.11.1/24 dev enp4s0 2>/dev/null || true

echo "Waiting for link to establish..."
sleep 3

echo "✓ Done! Testing connectivity..."
echo
sudo ethtool enp4s0 | grep -E "(Speed|Link detected)"
ping -c 2 10.0.11.2
