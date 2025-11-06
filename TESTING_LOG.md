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

**Result**: ⏳ IN PROGRESS - REBOOTING NOW (Nov 6, 20:15)
**Notes**: System reboot initiated to test persistence


### Test 2: Firmware Upgrade Survival ⏳
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