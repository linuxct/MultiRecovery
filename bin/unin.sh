#!/system/bin/sh

# Initialize Busybox path 
if [ -x "/system/xbin/busybox" ]; then
  BUSYBOX="/system/xbin/busybox"
elif [ -x "/system/bin/busybox" ]; then
  BUSYBOX="/system/bin/busybox"
else
  BUSYBOX="/data/local/tmp/recovery/busybox"
fi

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
if [ -f "/system/lib/modules/selinux_mod.ko" ]; then
    ${BUSYBOX} rm /system/lib/modules/selinux_mod.ko
fi

# Remove recovery script from system
if [ -f "/system/bin/recovery.sh" ]; then
    ${BUSYBOX} rm /system/bin/recovery.sh
fi

# Restore chargemon & e2fsck binary files
if [ -e /system/bin/chargemon.bin ]; then   
   CHARGEMON=`${BUSYBOX} sed -n 1p /system/bin/chargemon`
   if [ "${CHARGEMON}" = "#!/system/bin/sh" ] || [ "${CHARGEMON}" = "#!/system/xbin/busybox sh" ]; then
       ${BUSYBOX} mv /system/bin/chargemon.bin /system/bin/chargemon
   fi   
fi

# Don't touch if it isn't a shell script
if [ -e /system/bin/e2fsck.bin ]; then
   E2FSCK=`${BUSYBOX} sed -n 1p /system/bin/e2fsck` # double checks if e2fsck is not a binary..
   if [ "${E2FSCK}" = "#!/system/bin/sh" ] || [ "${E2FSCK}" = "#!/system/xbin/busybox sh" ]; then
      ${BUSYBOX} mv /system/bin/e2fsck.bin /system/bin/e2fsck
   fi
fi

${BUSYBOX} mount -o remount,ro /system
