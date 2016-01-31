#!/system/bin/sh

if [ -x "/system/xbin/busybox" ]; then
   BUSYBOX="/system/xbin/busybox"
elif [ -x "/system/bin/busybox" ]; then
   BUSYBOX="/system/bin/busybox"
else
   BUSYBOX=/data/local/tmp/recovery/busybox
fi

SET_ALIAS ()
{
   CAT="${BUSYBOX} cat"
   GREP="${BUSYBOX} grep"
}

OS_VERSION ()
{
	VERSION="jb_other"
        
        SET_ALIAS        
	if [ "$(${CAT} /system/build.prop | ${GREP} "ro.build.version.release" | ${GREP} -c "5.1.1")" -eq 1 ]; then
		VERSION="5.1.1" # 18.6.A.0.X
		VER_LP=true
	else
		VER_LP=false
	fi

	if [ "$(${CAT} /system/build.prop | ${GREP} "ro.build.version.release" | ${GREP} -c "4.4.4")" -eq 1 ]; then
		VERSION="4.4.4" # 18.3.1.X.X
		VER_KK4=true
	else
		VER_KK4=false
	fi

	if [ "$(${CAT} /system/build.prop | ${GREP} "ro.build.version.release" | ${GREP} -c "4.3")" -eq 1 ]; then
		VERSION="4.3" # 18.0.C.1.13
		VER_KK3=true
	else
		VER_KK3=false
	fi

}

OS_VERSION
echo "Getting version number "
if [ "$VERSION" = '5.1.1' ]; then
     echo "Android :" ${VERSION}
elif [ "$VERSION" = '4.4.4' ]; then
     echo "Android :" ${VERSION}
elif [ "$VERSION" = '4.3' ]; then
     echo "Android :" ${VERSION}
else
    echo "Version  is  ${VERSION}  NOT compatible "
    exit 1;
fi

echo "remount /system writable"
${BUSYBOX} mount -o remount,rw /system

# Checking android version first, because we not using byeselinux on android versions older than lollipop.
if [ "$VERSION" = "5.1.1" ]; then
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
${BUSYBOX} chown 0.2000 /system/xbin/busybox
${BUSYBOX} chmod 755 /system/xbin/busybox

echo "copy recoveries to system."
${BUSYBOX} cp /data/local/tmp/recovery/twrp.cpio /system/bin/twrp.cpio
${BUSYBOX} chown 0.0 /system/bin/twrp.cpio
${BUSYBOX} chmod 644 /system/bin/twrp.cpio

${BUSYBOX} cp /data/local/tmp/recovery/philz.cpio /system/bin/philz.cpio
${BUSYBOX} chown 0.0 /system/bin/philz.cpio
${BUSYBOX} chmod 644 /system/bin/philz.cpio

${BUSYBOX} cp /data/local/tmp/recovery/cwm.cpio /system/bin/cwm.cpio
${BUSYBOX} chown 0.0 /system/bin/cwm.cpio
${BUSYBOX} chmod 644 /system/bin/cwm.cpio

if ${VER_KK4} || ${VER_KK3} ; then
        echo "copy e2fsck replacement to system."
        if [ ! -f "/system/bin/e2fsck.bin" ]; then
                ${BUSYBOX} mv /system/bin/e2fsck /system/bin/e2fsck.bin
	fi
        ${BUSYBOX} cp /data/local/tmp/recovery/dummy.sh /system/bin/e2fsck
        ${BUSYBOX} chown 0.0 /system/bin/e2fsck
        ${BUSYBOX} chmod 755 /system/bin/e2fsck
fi

if [ "$VERSION" = "5.1.1" ]; then
        echo "copy chargemon replacement to system."
        if [ ! -f "/system/bin/chargemon.bin" ]; then
		${BUSYBOX} mv /system/bin/chargemon /system/bin/chargemon.bin
        fi
        ${BUSYBOX} cp /data/local/tmp/recovery/dummy.sh /system/bin/chargemon
        ${BUSYBOX} chown 0.0 /system/bin/chargemon
        ${BUSYBOX} chmod 755 /system/bin/chargemon
fi

echo "copy recovery script to system."
${BUSYBOX} cp /data/local/tmp/recovery/recovery.sh /system/bin/recovery.sh
${BUSYBOX} chown 0.0 /system/bin/recovery.sh
${BUSYBOX} chmod 755 /system/bin/recovery.sh


echo "remount /system read only"
${BUSYBOX} mount -o remount,ro /system
