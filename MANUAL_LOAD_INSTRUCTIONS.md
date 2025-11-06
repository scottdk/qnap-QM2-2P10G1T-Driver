# Manual Driver Loading Instructions

## Quick Start - After Every Reboot

Simply run:
```bash
cd /mnt/Pool1/home/dockuser/dev/qnap-QM2-2P10G1T
sudo ./load_tn40xx_manual.sh
```

That's it! The script will:
1. Remove all conflicting drivers
2. Load tn40xx with MV88X3310 PHY firmware
3. Bring up the `enp4s0` interface
4. Configure IP address 10.0.11.1/24
5. Test connectivity to 10.0.11.2

## Expected Output

```
=========================================
Manual tn40xx Driver Loader
=========================================

[1/5] Removing ALL conflicting drivers...
✓ All drivers removed
[2/5] Loading tn40xx module...
✓ tn40xx loaded
[3/5] Checking for network interface...
✓ Found interface: enp4s0
[4/5] Configuring interface enp4s0...
✓ Interface configured
[5/5] Testing connectivity...
✓ SUCCESS! Connectivity to 10.0.11.2 working!

=========================================
Status Summary:
=========================================
        Speed: 10000Mb/s
        Duplex: Full
        Link detected: yes
    inet 10.0.11.1/24 brd 10.0.11.255 scope global enp4s0

Driver loaded successfully!
Interface: enp4s0 at 10.0.11.1/24
```

## Why This Works

The key discovery: The built-in kernel `tehuti` driver loads first during boot and binds to the QNAP device. When you try to load `tn40xx` afterwards, it can't bind because tehuti is already attached.

**The solution**: Remove ALL drivers first, then load `tn40xx`. This allows tn40xx to bind to the device and load the MV88X3310 PHY firmware properly.

**Critical commands in the script**:
```bash
sudo rmmod tn40xx tehuti_qnap tehuti 2>/dev/null || true  # Remove everything
sudo insmod driver-source/tn40xx.ko                         # Load tn40xx
```

## Troubleshooting

### Script fails with "interface not found"
- Check that the QNAP card is detected: `lspci | grep Tehuti`
- Check if driver loaded: `lsmod | grep tn40xx`
- Check kernel messages: `sudo dmesg | tail -20`

### No connectivity after script runs
- Verify link is up: `sudo ethtool enp4s0`
- Should show: `Speed: 10000Mb/s`, `Link detected: yes`
- Check peer device (10.0.11.2) is powered on and connected

### Interface has null MAC (00:00:00:00:00:00)
- PHY firmware didn't load - driver binding issue
- Re-run the script: `sudo ./load_tn40xx_manual.sh`

## Files Needed

The script requires:
- `driver-source/tn40xx.ko` - Precompiled driver module
- `driver-source/x3310fw_0_3_4_0_9445.hdr` - PHY firmware (embedded in driver)

Both files are already in the repository.

## Why Not Automatic?

We discovered that **PCI driver bind/unbind operations cause kernel panics** on this TrueNAS system (kernel 6.12.15). Every attempt to use sysfs commands like:
- `echo "0000:04:00.0" > /sys/bus/pci/drivers/tn40xx/bind`  
- `echo "1fc9 4027" > /sys/bus/pci/drivers/tn40xx/new_id`

...resulted in immediate system reboot.

The manual script avoids these dangerous operations and uses safe module loading instead.

## Alternative: Quick Commands

If you just need to quickly reload the driver:

```bash
cd /mnt/Pool1/home/dockuser/dev/qnap-QM2-2P10G1T
sudo rmmod tn40xx tehuti_qnap tehuti 2>/dev/null || true
sudo insmod driver-source/tn40xx.ko
sleep 2
sudo ip link set enp4s0 up
sudo ip addr add 10.0.11.1/24 dev enp4s0
```

## Success Criteria

After running the script, verify:
- ✅ `lsmod | grep tn40xx` shows module loaded
- ✅ `ip link show enp4s0` shows `UP,LOWER_UP`
- ✅ MAC address is NOT `00:00:00:00:00:00`
- ✅ `sudo ethtool enp4s0` shows `Speed: 10000Mb/s`
- ✅ `ping 10.0.11.2` works

---

**Last Updated**: November 6, 2025  
**Tested On**: TrueNAS SCALE 25.04.2.4, Kernel 6.12.15-production+truenas
