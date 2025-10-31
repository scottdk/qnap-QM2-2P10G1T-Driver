Contributing
=============

Thanks for considering contributions. A few guidelines:

- Keep changes small and focused.
- If you improve device support, include hardware PCI IDs and a short test plan.
- Preserve original license notices in driver code (this project is based on GPLv2 Tehuti sources).
- Open a PR with a clear description of the change and test results.

Local testing notes
- Build with `make` against the running TrueNAS kernel headers.
- Load with `sudo insmod ./tehuti_qnap.ko` and check `dmesg` for messages.
