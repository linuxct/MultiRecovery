Multiple Recovery solution for Xperia M2
========================================

Recovey installer / flashable zip for locked boot loader. Compatible with Windows/Linux/Mac.

Uses chargemon and e2fsck as hijack binary.

Requirements:
- Rooted Sony Xperia M2 device
- Installed ADB Interface Driver
- Stock firmwares 18.0.C.1.13 or above

Recovery Options:
- CWM 6.0.5.1
- Philz touch 6.59.0
- TWRP 2.8.1.0

Installation:
- Extract package to your pc.
- Run the script to install the recovery.

To enter recovery, press the appropriate button on boot when the cyan led glows.
- Volume Down   - Philz
- Volume UP     - TWRP
- Camera button - CWM

Changelog:

v0.8
- Added installation script with separate adb support for Linux OS.
- Stripped version of byeselinux LKM to reduce size.
- Relevant bug fixes, update LEDs (media and notifications one) in regular Xperia M2.
- MOBILE [aka Emergency] version, which consists on a shell script that can be executed from an elevated Terminal Emulator.

v0.7
- Use of Chargemon instead of e2fsck as base script to trigger the Recovery.
- Usage of ByeSELinux kernel module to change SE Linux Status from Enforcing to Permissive during boot. (Many thanks to NUT and zxz0O0). 
- (After the user interaction time span, the module is unloaded to continue to regular boot.)
- The same 3 recoveries as KitKat are included, TWRP, PhilZ and CWM. 
- Compatibility with legacy e2fsck script inside the installer (Option number 2: "Install MultiRecovery (Android 4.4.x)")
- New Linux/OSX installer script (WIP, only supports installation of Android 5.1.1 Recovery. Will be improved in the future).
- Updated BusyBox.

v0.6 
- Fixed USB connection, adb shell commands can be used while device is in recovery mode.

v0.5 
- Added button management, vol-up for TWRP, camera button for CWM.
- Added TWRP Recovery v2.8.1.0 to installer.

v0.4
- Temp fixes in a script to catch key events. 

v0.3 
- Changes in recovery.fstab to avoid messages about /misc partition.
- Used a new compilation of busybox to correct error: unzip zip flags 1 and 8 are not supported.

v0.2 
- The zip files is packed with other update-binary.
- The flashable zip can be used with PRFcreator.

Authors: Sergio Castell (linuxct) and Aleksandar (AleksJ).

Thanks to: 
Phil3759 for source.
Team Win Recovery Project. 
DooMLoRD for ramdisk.
rachitrawat and [NUT] for recovery installer.
zxz0O0 for PRFCreator and ByeSELinux.
Andrej732 for improvements on installer script.
