# QNAP QM2-2P10G1T TrueNAS Driver

A Linux driver solution for the QNAP QM2-2P10G1T 10GbE network card on TrueNAS systems. This card uses the Tehuti TN9710P chipset (PCI ID: 1fc9:4027) which is not recognized by the stock Linux kernel driver.

## 🚀 Quick Start

1. **Clone or download this repository** to your TrueNAS system
2. **Navigate to the driver directory:**
   ```bash
   cd driver-development
   ```
3. **Run the automated installer:**
   ```bash
   sudo ./install_qnap_driver.sh
   ```
4. **Verify the installation:**
   ```bash
   ./check_status.sh
   ```

## 📋 What This Project Provides

- **Modified Tehuti driver** with TN9710P PCI ID support (1fc9:4027)
- **Automated installation scripts** for easy setup and maintenance
- **Status checking tools** to verify driver functionality
- **Complete documentation** for troubleshooting and customization
- **TrueNAS update recovery** procedures

## 🔧 Hardware Compatibility

**Supported Hardware:**
- QNAP QM2-2P10G1T M.2 to 10GbE adapter
- Tehuti TN9710P chipset (PCI ID: 1fc9:4027)

**Tested Environment:**
- TrueNAS SCALE (Linux kernel 6.12.15-production+truenas)
- Other Linux distributions with kernel headers

## 📁 Project Structure

```
qnap-QM2-2P10G1T/
├── README.md                    # This file
├── PROJECT_STATUS.md            # Current development status
├── driver-development/          # Main driver implementation
│   ├── tehuti_modified.c        # Modified driver source
│   ├── tehuti.h                 # Driver headers
│   ├── Makefile                 # Build configuration
│   ├── install_qnap_driver.sh   # Automated installer
│   ├── check_status.sh          # Status verification tool
│   ├── README.md                # Detailed technical documentation
│   ├── LICENSE                  # GPLv2 license
│   ├── CONTRIBUTING.md          # Contribution guidelines
│   └── CHANGELOG.md             # Version history
└── drivers/                     # Reference drivers and documentation
    └── tn40xx-driver-master/    # Upstream Tehuti driver reference
```

## ⚡ Installation Methods

### Method 1: Automated Installation (Recommended)
```bash
cd driver-development
sudo ./install_qnap_driver.sh
```

### Method 2: Manual Installation
```bash
cd driver-development
make                              # Build the driver
sudo insmod ./tehuti_qnap.ko     # Load the module
sudo ip link set enp4s0 address 02:11:22:33:44:55  # Set MAC if needed
sudo ip link set enp4s0 up       # Bring interface up
```

## 🔍 Verification

After installation, verify the driver is working:

```bash
cd driver-development
./check_status.sh
```

Expected output when working correctly:
```
=== QNAP TN9710P Driver Status ===
PCI Device: Found at 04:00.0
Driver Module: tehuti_qnap loaded
Interface: enp4s0 exists and UP
Link Status: Link detected (depends on cable connection)
Speed: 10000Mb/s
```

## 🛠️ Troubleshooting

### Common Issues

**1. Interface shows NO-CARRIER**
- **Cause:** No physical connection or peer not ready
- **Solution:** Connect 10GbE cable to another 10GbE-capable device

**2. MAC address shows as 00:00:00:00:00:00**
- **Cause:** EEPROM read failure (known issue with some TN9710P cards)
- **Solution:** Automatically handled by installer (sets local MAC)

**3. Module build fails with OOM (Out of Memory)**
- **Cause:** Insufficient RAM during compilation
- **Solution:** Disable parallel builds: `make -j1`

**4. Driver disappears after TrueNAS update**
- **Cause:** System updates overwrite kernel modules
- **Solution:** Re-run installer: `sudo ./install_qnap_driver.sh`

### Debug Commands

```bash
# Check if driver is loaded
lsmod | grep tehuti

# View kernel messages
sudo dmesg | grep -i tehuti

# Check interface details
ip link show enp4s0
sudo ethtool enp4s0

# Check PCI device
lspci -d 1fc9:4027 -v
```

## 🌐 Network Configuration Example

After the driver is loaded, configure networking:

**On TrueNAS (example):**
```bash
sudo ip addr add 10.0.10.1/24 dev enp4s0
sudo ip link set enp4s0 up
```

**On peer system:**
```bash
sudo ip addr add 10.0.10.2/24 dev <your-10gb-interface>
sudo ip link set <your-10gb-interface> up
```

**Test connectivity:**
```bash
ping 10.0.10.2  # From TrueNAS
```

## 📈 Performance Testing

Use iperf3 to test 10GbE performance:

**On peer system:**
```bash
iperf3 -s
```

**On TrueNAS:**
```bash
iperf3 -c 10.0.10.2 -P 4 -t 10
```

Expected results: ~9.4+ Gbps for 10GbE links

## 🔄 Maintenance

### After TrueNAS Updates

TrueNAS system updates will remove custom kernel modules. To restore:

```bash
cd /path/to/qnap-QM2-2P10G1T/driver-development
sudo ./install_qnap_driver.sh
```

### Automatic Recovery (Future Enhancement)

Consider setting up a systemd service or cron job to automatically reinstall the driver after reboots.

## 🤝 Contributing

We welcome contributions! Please see [`driver-development/CONTRIBUTING.md`](driver-development/CONTRIBUTING.md) for guidelines.

**Common contribution areas:**
- Testing on different kernel versions
- EEPROM/MAC address detection improvements
- DKMS packaging for automatic rebuilds
- Performance optimizations
- Documentation improvements

## 📄 License

This project is licensed under the GNU General Public License v2.0 - see the [`LICENSE`](driver-development/LICENSE) file for details.

**Important:** This project modifies GPL-licensed Tehuti driver code. Original copyright holders retain their rights.

## 🔗 Related Projects

- [tn40xx-driver](drivers/tn40xx-driver-master/) - Upstream Tehuti driver reference
- [Linux Kernel Tehuti Driver](https://github.com/torvalds/linux/blob/master/drivers/net/ethernet/tehuti/tehuti.c) - Mainline kernel version

## ⚠️ Disclaimer

This is an unofficial driver modification. Use at your own risk. The authors are not responsible for any hardware damage or data loss.

**For production environments:** Test thoroughly in a non-production environment first.

## 📞 Support

- **Issues:** Open an issue on GitHub
- **Documentation:** See [`driver-development/README.md`](driver-development/README.md) for detailed technical information
- **Status:** Check [`PROJECT_STATUS.md`](PROJECT_STATUS.md) for current development status

## 🎯 Roadmap

- ✅ **Phase 1:** Basic driver functionality (COMPLETED)
- ✅ **Phase 2:** Installation automation (COMPLETED)
- 🔄 **Phase 3:** Connectivity testing (IN PROGRESS)
- 📋 **Phase 4:** DKMS integration for persistence
- 📋 **Phase 5:** Upstream kernel submission
- 📋 **Phase 6:** Performance optimization

---

**Last Updated:** November 1, 2025  
**Status:** Ready for connectivity testing  
**Compatibility:** TrueNAS SCALE, Linux kernel 6.x+