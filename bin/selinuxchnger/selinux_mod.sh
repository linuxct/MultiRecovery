#!/data/local/tmp/recovery/busybox sh

BUSYBOX="/data/local/tmp/recovery/busybox"

if [ ! -f /data/local/tmp/recovery/selinux_mod.ko ]; then
	echo "error patching kernel module. File not found."
	exit 1
fi

if [ ! -f /data/local/tmp/recovery/copymodulecrc ]; then
	echo "error: copymodulecrc not found"
	exit 1
fi

$BUSYBOX chmod 0755 /data/local/tmp/recovery/copymodulecrc

for module in /system/lib/modules/*.ko; do
	/data/local/tmp/recovery/copymodulecrc $module /data/local/tmp/recovery/selinux_mod.ko 1> /dev/null
done

$BUSYBOX mount -o remount,rw /system
if [ "$?" != "0" ]; then
        echo "remount R/W failed, installing SELinux mode changer aborted!"
        exit 1
fi


$BUSYBOX cp /data/local/tmp/recovery/selinux_mod.ko /system/lib/modules/selinux_mod.ko
$BUSYBOX chmod 644 /system/lib/modules/selinux_mod.ko

if [ "$?" == "0" ]; then

	echo "!!selinux_mod installed succesfully!!"
	exit 0

fi

echo "SELinux mode changer installation failed!"

exit 1
