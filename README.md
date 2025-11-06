# QNAP QM2-2P10G1T 10GbE Driver for TrueNAS SCALE

This repository contains the complete driver package for the **QNAP QM2-2P10G1T** (TN9710P chipset) 10 Gigabit Ethernet card to work properly on **TrueNAS SCALE**.

## 🎯 Quick Install (Recommended Method)

For the QNAP QM2-2P10G1T card, you **MUST** use the tn40xx driver with MV88X3310 PHY firmware support:

```bash
cd driver-source
sudo ./install_mv88x3310.sh
```

This will:
- Generate MV88X3310 PHY header from firmware
- Build tn40xx driver with MV88X3310 support  
- Load the driver with proper PHY initialization
- Configure automatic loading on boot

## ✅ Verification

After installation, verify the driver is working:

```bash
# Check driver is loaded
lsmod | grep tn40xx

# Check interface (should show LOWER_UP and no NO-CARRIER)
ip link show enp4s0

# Check link speed (should show 10000Mb/s)
sudo ethtool enp4s0

# Configure IP and test
sudo ip addr add 10.0.11.1/24 dev enp4s0
ping 10.0.11.2  # Replace with your peer IP
```

Expected output:
- **Interface**: `<BROADCAST,MULTICAST,UP,LOWER_UP>`
- **Speed**: `10000Mb/s` 
- **Link detected**: `yes`

## 📁 Project Structure

```
qnap-QM2-2P10G1T/
├── driver-source/           # Clean driver source (USE THIS)
│   ├── *.c, *.h            # Source code
│   ├── x3310fw_*.hdr       # MV88X3310 PHY firmware  
│   ├── install_mv88x3310.sh # ⭐ Main installer script
│   ├── ensure_tn40xx_on_boot.sh # Boot persistence
│   ├── setup_dkms.sh       # DKMS setup (if available)
│   └── Makefile            # Build configuration
│
└── _archive/               # Historical development files
    ├── driver-development/ # Original simple driver attempts
    ├── github-release/     # Tested releases  
    ├── tn40xx-driver-working/ # Working build artifacts
    └── README.md, PROJECT_STATUS.md # Old documentation
```

## 🔧 Manual Build Process

If the install script fails, build manually:

```bash
cd driver-source

# Generate PHY header (if needed)
./mvidtoh.sh x3310fw_0_3_4_0_9445.hdr MV88X3310 MV88X3310_phy.h

# Build with MV88X3310 support
make clean
make MV88X3310=YES -j1

# Load driver
sudo rmmod tn40xx tehuti 2>/dev/null || true
sudo insmod ./tn40xx.ko

# Check kernel messages
sudo dmesg | tail -20
```

## 💾 Persistence Setup

The installer automatically configures persistence, but you can also set it up manually:

### Method 1: Systemd Service (Recommended for TrueNAS)
```bash
sudo cp /path/to/tn40xx-loader.service /etc/systemd/system/
sudo systemctl enable tn40xx-loader.service
```

### Method 2: Boot Script
```bash
sudo ./ensure_tn40xx_on_boot.sh
```

This creates:
- `/etc/modprobe.d/blacklist-tehuti.conf` - Prevents conflicts
- Systemd service for automatic loading

## ⚠️ Important Notes

### Why MV88X3310 PHY Firmware is Required

The QNAP QM2-2P10G1T uses a **TN9710P** chipset with **MV88X3310** PHY that requires specific firmware initialization:

- ❌ **Simple tehuti driver**: Loads but shows `NO-CARRIER` (no link)
- ✅ **tn40xx + MV88X3310 firmware**: Proper 10GbE link establishment

### Hardware Details
- **Card**: QNAP QM2-2P10G1T
- **Chipset**: TN9710P (Tehuti Networks) 
- **PCI ID**: `1fc9:4027` 
- **PHY**: MV88X3310 (requires firmware version 0.3.4.0)
- **Interface**: Typically appears as `enp4s0`

### Supported Speeds
- 10GbE (10000Mb/s) - Primary
- 5GbE (5000Mb/s)  
- 2.5GbE (2500Mb/s)
- 1GbE (1000Mb/s)
- 100Mbps

## 🐛 Troubleshooting

### No Link (NO-CARRIER)
```bash
# Check if wrong driver loaded
lsmod | grep -E "tehuti|tn40"

# If tehuti is loaded, switch to tn40xx
sudo rmmod tehuti
sudo ./install_mv88x3310.sh
```

### Build Failures  
```bash
# Install build dependencies
sudo apt update
sudo apt install build-essential linux-headers-$(uname -r)

# Try single-threaded build
make clean && make MV88X3310=YES -j1
```

### Driver Not Loading
```bash
# Check for conflicts
sudo dmesg | grep -i tn40
sudo modprobe -r tehuti tn40xx
sudo insmod ./tn40xx.ko
```

## 📋 Development History

This driver package was developed through extensive testing on TrueNAS SCALE 25.04.2.4:

1. **Simple tehuti driver**: Initial attempt using modified Tehuti driver
2. **tn40xx exploration**: Discovered need for PHY-specific support  
3. **MV88X3310 firmware**: Found and integrated PHY firmware requirements
4. **Working solution**: tn40xx + MV88X3310 firmware = 10GbE success

All development artifacts are preserved in `_archive/` for reference.

## 📄 License

This driver is based on the open-source tn40xx driver project. See individual source files for specific license information.

## 🆘 Support

1. **Check dmesg**: `sudo dmesg | grep -i tn40`
2. **Verify hardware**: `lspci | grep 1fc9:4027`  
3. **Interface status**: `ip link show` and `sudo ethtool <interface>`
4. **Review this README**: All common issues are covered above

---
**Success**: QNAP QM2-2P10G1T working at 10GbE on TrueNAS SCALE 25.04.2.4 ✅