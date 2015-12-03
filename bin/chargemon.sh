#!/system/xbin/busybox sh

# set variable paths
BUSYBOX=/system/xbin/busybox
VIB=/sys/class/timed_output/vibrator/enable
G_LED=/sys/class/leds/rgb_green/brightness
B_LED=/sys/class/leds/rgb_blue/brightness
R_LED=/sys/class/leds/rgb_red/brightness
WORKDIR="/cache/multirecovery"
GETPROP() {
	PROP=$(${BUSYBOX} grep "$VAR" /system/build.prop | ${BUSYBOX} awk -F'=' '{ print $NF }')
	if [ "$VAR" != "" -a "$PROP" != "" ]; then
		echo $PROP
	else
		echo "null"
	fi
}

# set busybox variables
MKDIR="${BUSYBOX} mkdir"
CHOWN="${BUSYBOX} chown"
CHMOD="${BUSYBOX} chmod"
TOUCH="${BUSYBOX} touch"
CAT="${BUSYBOX} cat"
SLEEP="${BUSYBOX} sleep"
KILL="${BUSYBOX} kill"
RM="${BUSYBOX} rm"
PS="${BUSYBOX} ps"
GREP="${BUSYBOX} grep"
AWK="${BUSYBOX} awk"
EXPR="${BUSYBOX} expr"
MOUNT="${BUSYBOX} mount"
LS="${BUSYBOX} ls"
HEXDUMP="${BUSYBOX} hexdump"
CP="${BUSYBOX} cp"

if [ ! -f /dev/recoverycheck ]; then

# remount rootfs rw
${MOUNT} -o remount,rw rootfs /

# Create work directory
if [ ! -d "${WORKDIR}" ]; then
	${MKDIR} ${WORKDIR}
	${CHOWN} system.cache ${WORKDIR}
	${CHMOD} 770 ${WORKDIR}
fi

# Clear work directory
if [ ! -e ${WORKDIR}/keycheck ]; then
	${RM} ${WORKDIR}/keyevent*
	${RM} ${WORKDIR}/keycheck_camera
	${RM} ${WORKDIR}/keycheck_camera2
	${RM} ${WORKDIR}/keycheck_up
	${RM} ${WORKDIR}/keycheck_down
	
fi

# Check recovery-boot file
if [ ! -e /cache/recovery/boot ];then

        # Trigger Blue LED
        echo 255 > ${B_LED}

        for EVENTDEV in $(${LS} /dev/input/event* )
		do
			SUFFIX="$(${EXPR} ${EVENTDEV} : '/dev/input/event\(.*\)')"
			${CAT} ${EVENTDEV} > ${WORKDIR}/keyevent${SUFFIX} &
		done
		${SLEEP} 2

		${PS} > ${WORKDIR}/ps.log
		${CHMOD} 660 ${WORKDIR}/ps.log

		for CATPROC in $(${PS} | ${GREP} /dev/input/event | ${GREP} -v grep | ${AWK} '{print $1}')
		do
		       ${KILL} -9 ${CATPROC}
		done

		# VOL-UP
		${HEXDUMP} ${WORKDIR}/keyevent* | ${GREP} -e '^.* 0001 0073 .... ....$' > ${WORKDIR}/keycheck_up
		# VOL-DOWN
		${HEXDUMP} ${WORKDIR}/keyevent* | ${GREP} -e '^.* 0001 0072 .... ....$' > ${WORKDIR}/keycheck_down
		# KEY_CAMERA_FOCUS
		${HEXDUMP} ${WORKDIR}/keyevent* | ${GREP} -e '^.* 0001 0210 .... ....$' > ${WORKDIR}/keycheck_camera
		${HEXDUMP} ${WORKDIR}/keyevent* | ${GREP} -e '^.* 0001 02fe .... ....$' > ${WORKDIR}/keycheck_camera2
fi

#Check if we need to kill SElinux :]
ANDROIDVER=`${BUSYBOX} echo "$(GETPROP ro.build.version.release) 5.0.0" | ${BUSYBOX} awk '{if ($2 != "" && $1 >= $2) print "lollipop"; else print "other"}'`
if [ "$ANDROIDVER" = "lollipop" ]; then
	if [ -e "/system/lib/modules/byeselinux.ko" ]; then
		${BUSYBOX} insmod /system/lib/modules/byeselinux.ko
	fi
fi

# PhilZ
if [ -s ${WORKDIR}/keycheck_down ]; then

        # turn LED Purple
		echo 255 > ${R_LED}

        # copy everything to /sbin
		${CP} /system/xbin/busybox /sbin/busybox
        ${CHOWN} root.shell /sbin/busybox
		${CHMOD}755 /sbin/busybox
		${CP} /system/bin/recovery.sh /sbin/recovery.sh
		${CHMOD} 755 /sbin/recovery.sh
        ${CP} /system/bin/philz.cpio /sbin/recovery.cpio
        ${CHMOD} 644 /sbin/recovery.cpio
		
        BUSYBOX=/sbin/busybox

        # trigger vibrator
		echo 200 > ${VIB}

        # exec recovery.sh
        exec /sbin/recovery.sh

fi

# TWRP
if [ -s ${WORKDIR}/keycheck_up ]; then

        # turn LED Green 
        echo 0 > ${B_LED}
		echo 255 > ${G_LED}

        # copy everything to /sbin
		${CP} /system/xbin/busybox /sbin/busybox
        ${CHOWN} root.shell /sbin/busybox
		${CHMOD}755 /sbin/busybox
		${CP} /system/bin/recovery.sh /sbin/recovery.sh
		${CHMOD} 755 /sbin/recovery.sh
        ${CP} /system/bin/twrp.cpio /sbin/recovery.cpio
        ${CHMOD} 644 /sbin/recovery.cpio
		
        BUSYBOX=/sbin/busybox

        # trigger vibrator
		echo 200 > ${VIB}

        # exec recovery.sh
        exec /sbin/recovery.sh

fi

# CWM
if [ -s ${WORKDIR}/keycheck_camera ] || [ -s ${WORKDIR}/keycheck_camera2 ]; then

        # turn LED White
        echo 255 > ${B_LED}
	    echo 255 > ${G_LED}
	    echo 255 > ${R_LED}

        # copy everything to /sbin
	    ${CP} /system/xbin/busybox /sbin/busybox
        ${CHOWN} root.shell /sbin/busybox
	    ${CHMOD}755 /sbin/busybox
	    ${CP} /system/bin/recovery.sh /sbin/recovery.sh
	    ${CHMOD} 755 /sbin/recovery.sh
        ${CP} /system/bin/cwm.cpio /sbin/recovery.cpio
        ${CHMOD} 644 /sbin/recovery.cpio
	        
        BUSYBOX=/sbin/busybox

        # trigger vibrator
	    echo 200 > ${VIB}

        # exec recovery.sh
        exec /sbin/recovery.sh
		
fi

# turn off LED
echo 0 > ${B_LED}
echo 0 > ${R_LED}
echo 0 > ${G_LED}

${BUSYBOX} touch /dev/recoverycheck

if [ "$ANDROIDVER" = "lollipop" ]; then
	#Remove SElinux kernel module
	/system/bin/rmmod byeselinux
fi

fi

# Continue regular boot (run stock chargemon)
/system/bin/chargemon.bin $*