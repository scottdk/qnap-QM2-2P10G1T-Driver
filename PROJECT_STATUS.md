# QNAP QM2-2P10G1T TrueNAS Driver Project - Continuation Guide

**Date Created:** November 1, 2025  
**Status:** READY FOR CONNECTIVITY TESTING  
**Next Major Step:** Connect 10GbE link to another computer and verify functionality

## Current Project State

### ✅ COMPLETED
- **Hardware Identified:** QNAP QM2-2P10G1T with Tehuti TN9710P chip (PCI ID: 1fc9:4027)
- **Driver Built:** Modified Tehuti driver (`tehuti_qnap.ko`) successfully compiled
- **Module Loaded:** Driver loads and creates `enp4s0` interface 
- **Interface UP:** Interface can be brought up with manually assigned MAC address
- **Scripts Created:** Install and status check scripts are ready
- **Documentation:** README, LICENSE, CONTRIBUTING, CHANGELOG created

### 🔄 CURRENT STATUS
- **Interface:** `enp4s0` exists and shows in TrueNAS web GUI as "disconnected" 
- **Link State:** NO-CARRIER (expected - no 10GbE peer connected yet)
- **MAC Address:** Uses locally-administered MAC (02:11:22:33:44:55) due to EEPROM read issue
- **Speed:** Advertised as 10000Mb/s

### 📁 PROJECT STRUCTURE
```
/mnt/Pool1/home/dockuser/dev/qnap-QM2-2P10G1T/
├── driver-development/           # Main work directory
│   ├── tehuti_qnap.ko           # Built driver module (READY)
│   ├── tehuti_modified.c        # Modified source with PCI ID 0x4027
│   ├── tehuti.h                 # Driver headers
│   ├── Makefile                 # Build configuration
│   ├── install_qnap_driver.sh   # Auto-install script (EXECUTABLE)
│   ├── check_status.sh          # Status checker (EXECUTABLE)
│   ├── README.md                # Comprehensive documentation
│   ├── LICENSE                  # GPLv2 license
│   ├── CONTRIBUTING.md          # Contribution guidelines
│   └── CHANGELOG.md             # Version history
└── PROJECT_STATUS.md            # This file
```

## IMMEDIATE NEXT STEPS (When You Return)

### 1. Connect 10GbE Hardware
Connect the QNAP card to another computer with 10GbE capability using appropriate cabling.

### 2. Verify Connectivity
```bash
cd /mnt/Pool1/home/dockuser/dev/qnap-QM2-2P10G1T/driver-development
./check_status.sh
```
**Expected Change:** "Link detected: yes" instead of "no"

### 3. Configure Network for Testing
On the **TrueNAS system**:
```bash
sudo ip addr add 10.0.11.1/24 dev enp4s0
sudo ip link set enp4s0 up
```

On the **peer system** (adjust interface name):
```bash
sudo ip addr add 10.0.11.2/24 dev <10gb-interface>
sudo ip link set <10gb-interface> up
```

### 4. Test Basic Connectivity
```bash
ping -c 5 10.0.11.2
```

### 5. Test Performance (Optional)
On peer system:
```bash
iperf3 -s
```

On TrueNAS:
```bash
iperf3 -c 10.0.11.2 -P 4 -t 10
```

## TECHNICAL DETAILS FOR TROUBLESHOOTING

### Current Driver Status
- **Module Name:** `tehuti_qnap` (separate from stock `tehuti`)
- **PCI Device:** `04:00.0` Tehuti TN9710P [1fc9:4027]
- **Kernel:** `6.12.15-production+truenas`
- **Firmware:** Uses `/lib/firmware/tehuti/bdx.bin` (already present)

### Known Issues & Workarounds
1. **MAC Address All Zeros:** EEPROM read fails, using manual MAC assignment
2. **Build Memory Issues:** First compile was killed (OOM), rebuild without parallel make worked
3. **TrueNAS Updates:** Will remove custom modules - use `install_qnap_driver.sh` to reapply

### Key Commands for Debugging
```bash
# Check if driver is loaded
lsmod | grep tehuti

# Check device binding
ls -la /sys/bus/pci/drivers/tehuti*/

# Check kernel messages
sudo dmesg | grep -i tehuti

# Check interface details
ip link show enp4s0
sudo ethtool enp4s0
```

## FUTURE ENHANCEMENTS (After Connectivity Confirmed)

### Priority 1: Persistence
- [ ] Create DKMS package for automatic rebuild after TrueNAS updates
- [ ] Add systemd service to auto-configure interface on boot

### Priority 2: Polish
- [ ] Initialize git repository (`git init`)
- [ ] Create GitHub repository and push
- [ ] Add proper MAC address detection (fix EEPROM read)

### Priority 3: Advanced
- [ ] Submit patch upstream to Linux kernel
- [ ] Create automated CI/testing
- [ ] Add support for other Tehuti variants

## IMPORTANT REMINDERS

### 🚨 After TrueNAS Updates
The custom driver will be lost after system updates. To restore:
```bash
cd /mnt/Pool1/home/dockuser/dev/qnap-QM2-2P10G1T/driver-development
sudo ./install_qnap_driver.sh
```

### 📋 Pre-Testing Checklist
- [ ] Physical 10GbE connection established
- [ ] Both systems have compatible 10GbE interfaces  
- [ ] Appropriate cables (Cat6A/7 for 10GBASE-T or SFP+ for fiber)
- [ ] Peer system configured with test IP address

### 🔧 If Issues Arise
1. Check `./check_status.sh` output
2. Run `sudo dmesg | tail -20` for recent kernel messages
3. Verify module is loaded: `lsmod | grep tehuti`
4. Check interface exists: `ip link show enp4s0`
5. If module missing, reload: `sudo ./install_qnap_driver.sh`

## SUCCESS CRITERIA

### Minimum Success
- [ ] Link detected: yes (in `check_status.sh`)
- [ ] Ping works between TrueNAS and peer
- [ ] Interface stays up consistently

### Full Success  
- [ ] 10Gbps or near-10Gbps throughput in iperf3
- [ ] No error counters in `ethtool -S enp4s0`
- [ ] Stable operation over extended testing

---

**Contact:** Continue in the same workspace when ready to proceed.  
**Repository Ready:** Yes - can be published to GitHub after connectivity verification.  
**Documentation Status:** Complete and ready for public use.