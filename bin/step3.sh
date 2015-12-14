#!/data/local/tmp/recovery/busybox sh

BUSYBOX=/data/local/tmp/recovery/busybox
VER=$(awk -F='/ro\.build\.version\.release/{print $NF}' /system/build.prop)

echo "remount /system writable"
${BUSYBOX} mount -o remount,rw /system

# Checking android version first, because byeselinux is causing issues with android versions older then lollipop.
ANDROIDVER=`${BUSYBOX} echo "$VER 5.0.0" | ${BUSYBOX} awk '{if ($2 != "" && $1 >= $2) print "lollipop"; else print "other"}'`
if [ "$ANDROIDVER" = "lollipop" ]; then
	# Thanks to zxz0O0 for this method
	if [ ! -e "/system/lib/modules/byeselinux.ko" ]; then
		echo "the byeselinux module does not yet exist, installing it now."
		${BUSYBOX} chmod 755 /data/local/tmp/recovery/byeselinux.sh
		${BUSYBOX} chmod 755 /data/local/tmp/recovery/modulecrcpatch
		/data/local/tmp/recovery/byeselinux.sh
	else
		echo "the byeselinux module exists, testing if the kernel accepts it."
		${BUSYBOX} insmod /system/lib/modules/byeselinux.ko
		if [ "$?" != "0" -a "$?" != "17" ]; then
			echo "that module is not accepted by the running kernel, will replace it now."
			${BUSYBOX} chmod 755 /data/local/tmp/recovery/modulecrcpatch
			${BUSYBOX} chmod 755 /data/local/tmp/recovery/byeselinux.sh
			/data/local/tmp/recovery/byeselinux.sh
		else
			echo "!! the module is accepted !!"
		fi
		/system/bin/rmmod byeselinux
	fi
fi

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

if [ "$ANDROIDVER" = "other" ]; then
	echo "copy e2fsck replacement to system."
	if [ ! -f "/system/bin/e2fsck.bin" ]; then
		${BUSYBOX} mv /system/bin/e2fsck /system/bin/e2fsck.bin
	fi
	${BUSYBOX} cp /data/local/tmp/recovery/e2fsck.sh /system/bin/e2fsck
	${BUSYBOX} chmod 755 /system/bin/e2fsck
fi

if [ "$ANDROIDVER" = "lollipop" ]; then
	echo "copy chargemon replacement to system."
	if [ ! -f "/system/bin/chargemon.bin" ]; then
		${BUSYBOX} mv /system/bin/chargemon /system/bin/chargemon.bin
	fi
	${BUSYBOX} cp /data/local/tmp/recovery/chargemon.sh /system/bin/chargemon
	${BUSYBOX} chmod 755 /system/bin/chargemon
fi

echo "copy recovery script to system."
${BUSYBOX} cp /data/local/tmp/recovery/recovery.sh /system/bin/recovery.sh
${BUSYBOX} chmod 755 /system/bin/recovery.sh

echo "remount /system read only"
${BUSYBOX} mount -o remount,ro /system