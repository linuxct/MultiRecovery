#!/data/local/tmp/recovery/busybox sh

BUSYBOX=/data/local/tmp/recovery/busybox

${BUSYBOX} mount -o remount,rw /system

# Remove cwm
if [ -e /system/bin/cwm.cpio ]; then
    ${BUSYBOX} rm /system/bin/cwm.cpio
fi

# Remove twrp
if [ -e /system/bin/twrp.cpio ]; then
    ${BUSYBOX} rm /system/bin/twrp.cpio
fi

# Remove philz
if [ -e /system/bin/philz.cpio ]; then
    ${BUSYBOX} rm /system/bin/philz.cpio
fi

# Remove old archives
if [ -e /system/bin/recovery.cpio ]; then
    ${BUSYBOX} rm /system/bin/recovery.cpio
fi

# Remove byeselinux lkm
if [ -f "/system/lib/modules/byeselinux.ko" ]; then
    ${BUSYBOX} rm /system/lib/modules/byeselinux.ko
fi

# Remove recovery script from system
if [ -f "/system/bin/recovery.sh" ]; then
    ${BUSYBOX} rm /system/bin/recovery.sh
fi

# Restore chargemon & e2fsck binary files
if [ -e /system/bin/chargemon.bin ]; then
   ${BUSYBOX} mv /system/bin/chargemon.bin /system/bin/chargemon
fi

if [ -e /system/bin/e2fsck.bin ]; then
   ${BUSYBOX} mv /system/bin/e2fsck.bin /system/bin/e2fsck
fi

${BUSYBOX} mount -o remount,ro /system
