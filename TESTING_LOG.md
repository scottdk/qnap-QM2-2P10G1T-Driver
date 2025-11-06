# QNAP QM2-2P10G1T Driver Testing Log

# QNAP QM2-2P10G1T Driver Testing Log

## Current Status (Before Testing) - ✅ CONFIRMED WORKING
- **Date**: November 6, 2025
- **TrueNAS Version**: SCALE 25.04.2.4
- **Kernel**: 6.12.15-production+truenas
- **Driver**: tn40xx with MV88X3310 PHY firmware
- **Interface**: enp4s0 at 10.0.11.1/24
- **Performance**: 10GbE (10000Mb/s) full duplex
- **Status**: ✅ WORKING - Network drives accessible
- **Persistence**: systemd service `tn40xx-loader.service` enabled and tested

## Service Status Update ✅
**Issue Found**: systemd service was pointing to old `tn40xx-driver/` path  
**Fix Applied**: Updated service to use `driver-source/ensure_tn40xx_on_boot.sh`  
**Result**: Service now shows `active (exited)` with `status=0/SUCCESS`  
**Test Command**: `sudo systemctl start tn40xx-loader.service` - PASSED

## Planned Tests

### Test 1: Reboot Persistence ⏳
**Objective**: Verify driver loads automatically after TrueNAS reboot

**Expected Behavior**:
- tn40xx driver should auto-load via systemd service
- enp4s0 interface should come up automatically
- 10GbE link should establish at 10000Mb/s
- Network connectivity should resume

**Verification Commands**:
```bash
# Check driver
lsmod | grep tn40xx

# Check interface 
ip addr show enp4s0
sudo ethtool enp4s0 | grep -E "(Speed|Link detected)"

# Check connectivity
ping -c 3 10.0.11.2

# Check what auto-loaded it
systemctl status tn40xx-loader.service
```

**Result**: ❌ FAILED - Critical Issue Discovered  
**Notes**: 
- **Reboot 1 (20:15)**: System rebooted, wrong driver loaded (tehuti instead of tn40xx)
- **Reboot 2 (21:25)**: Attempted manual driver binding - **KERNEL PANIC / REBOOT**
- **Reboot 3 (21:35)**: Second binding attempt - **KERNEL PANIC / REBOOT**  
- **Reboot 4 (21:49)**: Third binding attempt - **KERNEL PANIC / REBOOT**
- **Final State**: enp4s0 interface exists with null MAC (00:00:00:00:00:00), no driver bound

**⚠️ CRITICAL FINDING**: 
**PCI driver bind/unbind operations cause immediate kernel panic and system reboot on this hardware/kernel combination.**

Commands that trigger reboot:
```bash
# ALL OF THESE CAUSE KERNEL PANIC:
echo "0000:04:00.0" | sudo tee /sys/bus/pci/drivers/tn40xx/bind
echo "0000:04:00.0" | sudo tee /sys/bus/pci/drivers/tehuti/unbind  
echo "1fc9 4027" | sudo tee /sys/bus/pci/drivers/tn40xx/new_id
```

**Root Cause**: Built-in `tehuti` driver loads before custom `tn40xx`, preventing proper binding.

**Current Blockers**:
1. Cannot safely bind/unbind PCI drivers without kernel panic
2. Blacklisting tehuti driver created but not yet tested
3. Driver compilation fails due to memory constraints (process killed)
4. Precompiled module available but binding issue prevents use

**✅ SOLUTION FOUND (22:41)**:
**Manual Loading Procedure** - Works perfectly!

**Winning Formula**:
```bash
# Remove ALL drivers first (critical!)
sudo rmmod tn40xx tehuti_qnap tehuti 2>/dev/null || true
# Then load tn40xx - it auto-binds now
sudo insmod driver-source/tn40xx.ko
# Interface appears with valid MAC and PHY firmware
```

**Result**: 
- ✅ Interface `enp4s0` created with valid MAC (24:5e:be:2a:ee:26)
- ✅ Link established at 10000Mb/s full duplex
- ✅ Connectivity to 10.0.11.2 working
- ✅ All functionality restored

**Manual Script Created**: `load_tn40xx_manual.sh`  
**Documentation**: `MANUAL_LOAD_INSTRUCTIONS.md`

**User Decision**: Use manual loading after each reboot (preferred solution)


### Test 2: Firmware Upgrade Survival ⏸️
**Objective**: Verify driver continues working after TrueNAS firmware upgrade

**Pre-upgrade Status**:
- Driver: tn40xx loaded and working
- Kernel: 6.12.15-production+truenas
- Interface: enp4s0 UP at 10GbE

**Expected Behavior**:
- Driver should survive firmware upgrade
- If kernel changes, may need rebuild
- Systemd service should handle any issues

**Verification Commands**:
```bash
# Check new kernel version
uname -r

# Check driver status
./status.sh

# If driver missing, reinstall
sudo ./install.sh
```

**Result**: [ ] PASS / [ ] FAIL  
**Notes**:


## Recovery Instructions

If driver fails to load after either test:

### Quick Recovery:
```bash
cd /mnt/Pool1/home/dockuser/dev/qnap-QM2-2P10G1T
sudo ./install.sh
```

### Manual Recovery:
```bash
cd driver-source
sudo ./install_mv88x3310.sh
```

### Check Status:
```bash
./status.sh
```

## Files Available for Recovery
- **Main installer**: `install.sh` 
- **Driver source**: `driver-source/install_mv88x3310.sh`
- **All source files**: `driver-source/*.c`, `driver-source/*.h`
- **Firmware**: `driver-source/x3310fw_0_3_4_0_9445.hdr`
- **Boot persistence**: `driver-source/ensure_tn40xx_on_boot.sh`

## Success Criteria
✅ Both tests should show:
- tn40xx driver loaded
- enp4s0 interface UP with LOWER_UP
- Speed: 10000Mb/s, Link detected: yes  
- Ping to 10.0.11.2 successful
- Network drives accessible

## Expected Challenges
- **Test 1**: Should pass (persistence is configured)
- **Test 2**: May need rebuild if kernel version changes
- **Both**: Network config should persist in TrueNAS