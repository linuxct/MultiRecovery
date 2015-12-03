#!/sbin/busybox sh

_LDLIBPATH="$LD_LIBRARY_PATH"
_PATH="$PATH"

export LD_LIBRARY_PATH=".:/sbin:/system/vendor/lib:/system/lib"
export PATH="/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin"

#https://github.com/android/platform_system_core/commit/e18c0d508a6d8b4376c6f0b8c22600e5aca37f69
/sbin/busybox blockdev --setrw $(/sbin/find /dev/block/platform/msm_sdcc.1/by-name/ -iname "system")

if [ "$(/sbin/busybox cat /proc/mounts | /sbin/busybox grep 'sysfs' | /sbin/busybox grep '/sys' | /sbin/busybox wc -l)" = "0" ]; then
	/sbin/busybox mount -t sysfs sysfs /sys
fi

for LOCKINGPID in `/sbin/busybox lsof | awk '{print $1" "$2}' | grep -E "/bin|/system|/data|/cache" | awk '{print $1}'`; do
	BINARY=$(ps | grep " $LOCKINGPID " | grep -v "grep" | awk '{print $5}')        
	kill -9 $LOCKINGPID
done

export LD_LIBRARY_PATH="$_LDLIBPATH"
export PATH="$_PATH"

exit 0
