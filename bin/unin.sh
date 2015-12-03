#!/data/local/tmp/recovery/busybox sh
BUSYBOX=/data/local/tmp/recovery/busybox
${BUSYBOX} mount -o remount,rw /system

# remove cwm
if [ -e /system/bin/cwm.cpio ]; then
    ${BUSYBOX} rm /system/bin/cwm.cpio
fi

# remove twrp
if [ -e /system/bin/twrp.cpio ]; then
    ${BUSYBOX} rm /system/bin/twrp.cpio
fi

# remove philz
if [ -e /system/bin/philz.cpio ]; then
    ${BUSYBOX} rm /system/bin/philz.cpio
fi

if [ -e /system/bin/recovery.cpio ]; then
    ${BUSYBOX} rm /system/bin/recovery.cpio
fi

${BUSYBOX} rm /system/bin/recovery.sh

if [ -e /system/bin/chargemon.bin ]; then
   ${BUSYBOX} mv /system/bin/chargemon.bin /system/bin/chargemon
fi

if [ -e /system/bin/e2fsck.bin ]; then
   ${BUSYBOX} mv /system/bin/e2fsck.bin /system/bin/e2fsck
fi

${BUSYBOX} mount -o remount,ro /system
