#!/data/local/tmp/recovery/busybox sh

BUSYBOX=/data/local/tmp/recovery/busybox

echo "remount /system writable"
${BUSYBOX} mount -o remount,rw /system

echo "copy busybox to system."
${BUSYBOX} cp /data/local/tmp/recovery/busybox /system/xbin/busybox
${BUSYBOX} chown root.shell /system/xbin/busybox
${BUSYBOX} chmod 755 /system/xbin/busybox

echo "copy recoveries to system."
${BUSYBOX} cp /data/local/tmp/recovery/twrp.cpio /system/bin/twrp.cpio
${BUSYBOX} chmod 644 /system/bin/twrp.cpio
${BUSYBOX} cp /data/local/tmp/recovery/philz.cpio /system/bin/philz.cpio
${BUSYBOX} chmod 644 /system/bin/philz.cpio
${BUSYBOX} cp /data/local/tmp/recovery/cwm.cpio /system/bin/cwm.cpio
${BUSYBOX} chmod 644 /system/bin/cwm.cpio



echo "copy e2fsck replacement to system."
if [ ! -f "/system/bin/e2fsck.bin" ]; then
	${BUSYBOX} mv /system/bin/e2fsck /system/bin/e2fsck.bin
fi
${BUSYBOX} cp /data/local/tmp/recovery/e2fsck.sh /system/bin/e2fsck
${BUSYBOX} chmod 755 /system/bin/e2fsck

echo "copy recovery script to system."
${BUSYBOX} cp /data/local/tmp/recovery/recovery.sh /system/bin/recovery.sh
${BUSYBOX} chmod 755 /system/bin/recovery.sh

echo "remount /system read only"
${BUSYBOX} mount -o remount,ro /system