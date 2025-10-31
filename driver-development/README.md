# QNAP QM2-2P10G1T TN9710P Driver for TrueNAS

This project provides a small, focused set of files to enable a Tehuti TN9710P-based 10GbE card (QNAP QM2-2P10G1T) on TrueNAS systems where the stock kernel driver does not recognize the device ID (PCI ID 1fc9:4027).

The approach in this repository is conservative:
- Add the TN9710P PCI device ID into a copy of the in-tree Tehuti driver
- Build the modified driver as a separate module named `tehuti_qnap` to avoid overwriting the distribution-provided module
- Fall back to a manual MAC address if the hardware's EEPROM cannot be read

IMPORTANT: TrueNAS system updates will typically overwrite kernel modules or replace the kernel. You must re-run the build/install steps after a system update. See the "Reapply after updates" section below for a recommended, repeatable process.

Contents
- `tehuti_modified.c` — modified Tehuti driver source (driver code is based on the GPL Tehuti sources)
- `tehuti.h` — header used by the driver (kept as originally found in the kernel tree)
- `Makefile` — simple build helper that uses the running kernel headers
- `install_qnap_driver.sh` — convenience script to build and install the module and bring up the interface
- `check_status.sh` — helper to verify detection, driver load state, and link information
- `README.md` — this document

Quick start (tested on this TrueNAS setup)
1. Copy this directory to TrueNAS and cd into it.
2. Build the driver (recommended to run as non-root):

```bash
cd driver-development
make               # builds tehuti_qnap.ko
```

3. Install the module (requires root):

```bash
sudo insmod ./tehuti_qnap.ko
```

4. (Optional) Let the module claim the device or add the PCI id manually:

```bash
# If the module exported aliases for the device id, it will bind automatically.
# Otherwise, force the binding (example):
echo "1fc9 4027" | sudo tee /sys/bus/pci/drivers/tehuti_qnap/new_id
```

5. If the interface reports a zero MAC address (some TN9710P revisions don't expose the EEPROM correctly), set a local MAC and bring the interface up:

```bash
sudo ip link set enp4s0 address 02:11:22:33:44:55
sudo ip link set enp4s0 up
```

6. Verify with the included checker:

```bash
./check_status.sh
```

How it was tested here
- Kernel: `$(uname -r)` (this will vary on your system)
- The module is built against the system's kernel headers. Building may require memory — if a build is killed, retry with fewer parallel jobs (we use the stock Makefile which invokes the kernel build system).

Notes about stability and maintenance
- This is a compatibility patch/workaround. The proper long-term fix is an upstream driver that includes full support for the TN9710P and any associated EEPROM layout.
- System updates on TrueNAS that replace the kernel or kernel modules will remove this module. Keep this repository somewhere persistent and re-run `make && sudo insmod ./tehuti_qnap.ko` after updates. The `install_qnap_driver.sh` script automates the re-apply.

Publishing this repo
If you'd like to publish this on GitHub (recommended to help others):
1. Create a repository on GitHub
2. Locally initialize and commit (we include a helper below to initialize a git repo)
3. Push to your GitHub remote

Security / Legal
- This project contains / modifies GPL-licensed driver code; the original driver authors retain copyright. If you publish this repository, keep licensing information and attribution intact (GPLv2). See the `LICENSE` file.

Troubleshooting
- Build Killed / OOM: reduce parallelism (the kernel build system warns about jobserver). Run `make` without -j or with a smaller job count.
- Interface shows NO-CARRIER: no cable or the remote peer is not negotiating at 10Gb.
- MAC = 00:00:00:00:00:00: set a locally-administered MAC with `ip link set <iface> address ...` as above.
- Module load errors: run `sudo dmesg | tail -50` and post the output if you need help.

Maintainer note
If you post this publicly, include `tehuti` vendor attribution (Tehuti Networks) and keep the driver under GPLv2 as required by the original code.

License
This project is released under the GPLv2 (see `LICENSE`).