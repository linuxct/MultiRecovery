#!/system/bin/sh


# Initialize Busybox path 
if [ -x "/system/xbin/busybox" ]; then
   BUSYBOX="/system/xbin/busybox"
elif [ -x "/system/bin/busybox" ]; then
   BUSYBOX="/system/bin/busybox"
else
   BUSYBOX=""
fi

VIB=/sys/class/timed_output/vibrator/enable
G_LED=/sys/class/leds/rgb_green/brightness
B_LED=/sys/class/leds/rgb_blue/brightness
R_LED=/sys/class/leds/rgb_red/brightness

# illumination bar paths
set0=/sys/class/illumination/0
set1=/sys/class/illumination/1
set2=/sys/class/illumination/2
set3=/sys/class/illumination/3
set4=/sys/class/illumination/4
set5=/sys/class/illumination/5
set6=/sys/class/illumination/6
set7=/sys/class/illumination/7
set8=/sys/class/illumination/8

LOG_PATH="/cache/multirecovery"
LOG_FILE="${LOG_PATH}/mr.log"
WORKDIR="${LOG_PATH}"

# Function for logging
ECHOL(){
  echo "$*" >> ${LOG_FILE}
  return 0
}
EXECL(){
  echo "$*" >> ${LOG_FILE}
  $* 2 >> ${LOG_FILE}
  _RET=$?
  echo "RET=${_RET}" >> ${LOG_FILE}
  return ${_RET}
}

# Predefined applet names
SET_ALIASES ()
{
  if [ -n "${BUSYBOX}" ] ; then
     MKDIR="${BUSYBOX} mkdir"
     CHOWN="${BUSYBOX} chown"
     CHMOD="${BUSYBOX} chmod"
     TOUCH="${BUSYBOX} touch"
	 TEE="${BUSYBOX} tee"
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
  fi  
}

# function to detect the installed Android version
OS_VERSION ()
{
	VERSION="jb_other"

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

if [ ! -f /dev/recoverycheck -o -e /cache/recovery/boot -a -n "${BUSYBOX}" ]; then

	SET_ALIASES

	# Remount rootfs rw
	${MOUNT} -o remount,rw rootfs /

	# Work directory & logfile rotate
	if [ ! -d "${LOG_PATH}" ]; then
		${MKDIR} ${LOG_PATH}
		${CHOWN} 1000.2001 ${LOG_PATH}
		${CHMOD} 770 ${LOG_PATH}
	else
		if [ -f ${LOG_FILE} ]; then
			${RM} ${LOG_FILE}
			${RM} ${WORKDIR}/keyevent*
			${RM} ${WORKDIR}/keycheck_camera
			${RM} ${WORKDIR}/keycheck_camera2
			${RM} ${WORKDIR}/keycheck_up
			${RM} ${WORKDIR}/keycheck_down
		fi
		${TEE} ${LOG_FILE}
		${CHMOD} 660 ${LOG_FILE}
	fi

	if [ ! -d "${WORKDIR}" ]; then
		${MKDIR} ${WORKDIR}
		${CHOWN} 1000.2001 ${WORKDIR}
		${CHMOD} 770 ${WORKDIR}
	fi

	# Trigger BOTH Blue LEDs
	echo 255 > ${B_LED}
	echo 0x5 > ${set0}

	# Initialize illumination bar variables
	echo 0xFF > ${set6}
	echo 0x0  > ${set7}
	echo 0x3B > ${set8}
	echo 0x11 > ${set4} # set4 must be last always, don't ask why

	for EVENTDEV in $(${LS} /dev/input/event* )
	do
	  SUFFIX="$(${EXPR} ${EVENTDEV} : '/dev/input/event\(.*\)')"
	  ${CAT} ${EVENTDEV} > ${WORKDIR}/keyevent${SUFFIX} &
	done
	${SLEEP} 2

	${PS} >> ${LOG_FILE}

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

	OS_VERSION
	# Check if we need to change SELinux modes
	mod_load=false;
	if [ "$VER_LP" = true ] ; then
		ECHOL "# running version is lollipop..."
		if [ -e /system/lib/modules/selinux_mod.ko ]; then
		   ${BUSYBOX} insmod /system/lib/modules/selinux_mod.ko
		fi
		if [ "$?" == "0" ]; then
		   ECHOL "# loading selinux_mod..."
	       mod_load=true;
		fi
	fi

# PhilZ
if [ -s ${WORKDIR}/keycheck_down ]; then

        # Turn BOTH LEDs Purple
        echo 255 > ${R_LED}
	echo 0xDB > ${set6}
	echo 0xFF > ${set7}
	echo 0x0 > ${set8}
	echo 0x5 > ${set4}

        # Copy everything to /sbin
        ${CP} /system/xbin/busybox /sbin/busybox
        ${CHOWN} 0.2000 /sbin/busybox
        ${CHMOD} 755 /sbin/busybox

        ${CP} /system/bin/recovery.sh /sbin/recovery.sh
        ${CHOWN} 0.0 /sbin/recovery.sh
        ${CHMOD} 755 /sbin/recovery.sh

        ${CP} /system/bin/philz.cpio /sbin/recovery.cpio
        ${CHOWN} 0.0 /sbin/recovery.cpio
        ${CHMOD} 644 /sbin/recovery.cpio

        BUSYBOX=/sbin/busybox

        # trigger vibrator
        echo 200 > ${VIB}

        # exec recovery.sh
        exec /sbin/recovery.sh

fi

# TWRP
if [ -s ${WORKDIR}/keycheck_up ]; then

        # Turn BOTH LEDs Green 
        echo 0 > ${B_LED}
        echo 255 > ${G_LED}
        echo 0xF > ${set6}
        echo 0xFF > ${set7}
        echo 0xFF > ${set8}
        echo 0x11 > ${set4}

        # Copy everything to /sbin
        ${CP} /system/xbin/busybox /sbin/busybox
        ${CHOWN} 0.2000 /sbin/busybox
        ${CHMOD} 755 /sbin/busybox

        ${CP} /system/bin/recovery.sh /sbin/recovery.sh
        ${CHOWN} 0.0 /sbin/recovery.sh
        ${CHMOD} 755 /sbin/recovery.sh

        ${CP} /system/bin/twrp.cpio /sbin/recovery.cpio
        ${CHOWN} 0.0 /sbin/recovery.cpio
        ${CHMOD} 644 /sbin/recovery.cpio
		
        BUSYBOX=/sbin/busybox

        # Trigger vibrator
        echo 200 > ${VIB}

        # exec recovery.sh
        exec /sbin/recovery.sh

fi

# CWM
if [ -s ${WORKDIR}/keycheck_camera ] || [ -s ${WORKDIR}/keycheck_camera2 ]; then

        # Turn BOTH LEDs White
        echo 255 > ${B_LED}
        echo 255 > ${G_LED}
        echo 255 > ${R_LED}
        echo 0xFF > ${set6}
        echo 0xFF > ${set7}
        echo 0xFF > ${set8}
        echo 0x15 > ${set4}

        # Copy everything to /sbin
        ${CP} /system/xbin/busybox /sbin/busybox
        ${CHOWN} 0.2000 /sbin/busybox
        ${CHMOD}755 /sbin/busybox

        ${CP} /system/bin/recovery.sh /sbin/recovery.sh
        ${CHOWN} 0.0 /sbin/recovery.sh
        ${CHMOD} 755 /sbin/recovery.sh

        ${CP} /system/bin/cwm.cpio /sbin/recovery.cpio
        ${CHOWN} 0.0 /sbin/recovery.cpio
        ${CHMOD} 644 /sbin/recovery.cpio
	        
        BUSYBOX=/sbin/busybox

        # Trigger vibrator
        echo 200 > ${VIB}

        # exec recovery.sh
        exec /sbin/recovery.sh
		
fi

# Turn off all LEDs
echo 0 > ${B_LED}
echo 0 > ${R_LED}
echo 0 > ${G_LED}
echo 0x0 > ${set6}
echo 0x0 > ${set7}
echo 0x0 > ${set8}
echo 0x0 > ${set4}

${BUSYBOX} touch /dev/recoverycheck

fi # end of recoverycheck statement

# Continue regular boot (run stock binary)
if [ "$VER_KK3" = true ] || [ "$VER_KK4" = true ] ; then
    /system/bin/e2fsck.bin $*
	ECHOL "# running version is KitKat..."
else
    if [ "$mod_load" = true ] ; then
        ${BUSYBOX} rmmod selinux_mod
		ECHOL "# unloading selinux_mod..."
    fi
    exec /system/bin/chargemon.bin # run chargemon binary.
fi

