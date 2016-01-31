#!/bin/bash

set -e

LOCAL_DIR=`dirname $0`
LOCAL_NAME=adb
ADB=${LOCAL_DIR}/${LOCAL_NAME}
ADBB=../$ADB
chmod u+x adb

app_exists()
{
    type "$1" &> /dev/null ;
}

openurl()
{  
   if app_exists xdg-open ; then      
      xdg-open "$1"
   elif app_exists gnome-open ; then
      gnome-open "$1"      
   else
       echo "Couldn't detect the web browser to use."
   fi
}

baner()
{
    printf " ============================================ \n"
    printf " |    *** MultiRecovery Installer ***       | \n"
    printf " |         for Xperia M2 (& M2 Aqua)        | \n"
    printf " |      by AlexJ, Andrej732 & LinuxCT       | \n"
    printf " |   Based on NUT's and Rachit Rawat work   | \n"
    printf " =========================================== \n"
    printf "\n"
    printf " ===========================================\n"
    printf "  Connect Xperia M2 with USB debugging on.. \n"
    printf " ===========================================\n"
}

doAdb()
{
    $ADB kill-server
    $ADB start-server
    $ADB wait-for-device
    cd files
}

doInstall()
{
    printf "===============================================\n"
    printf "          Installing MultiRecovery             \n"
    printf "===============================================\n\n"
        
    $ADBB shell "mkdir /data/local/tmp/recovery"
    $ADBB push recovery.sh /data/local/tmp/recovery
    $ADBB push dummy.sh /data/local/tmp/recovery
    $ADBB push twrp/twrp.cpio /data/local/tmp/recovery
    $ADBB push philz/philz.cpio /data/local/tmp/recovery
    $ADBB push cwm/cwm.cpio /data/local/tmp/recovery
    $ADBB push byeselinux/byeselinux.ko /data/local/tmp/recovery
    $ADBB push byeselinux/byeselinux.sh /data/local/tmp/recovery
    $ADBB push byeselinux/modulecrcpatch /data/local/tmp/recovery
    $ADBB push busybox /data/local/tmp/recovery
    $ADBB push step3.sh /data/local/tmp/recovery
    $ADBB shell "chmod 755 /data/local/tmp/recovery/busybox"
    $ADBB shell "chmod 755 /data/local/tmp/recovery/step3.sh"
    $ADBB shell "su -c /data/local/tmp/recovery/step3.sh" && sleep 1
    $ADBB shell "rm -r /data/local/tmp/recovery"

    if [ $? -eq 0 ]; then
	printf "Installation done \nEnjoy...\n"
    else
        printf "Installation failed!\n"
    fi

}

doRemove()
{
    printf "===============================================\n"
    printf "          Uninstalling MultiRecovery\n         \n"
    printf "===============================================\n\n"
	
    $ADBB shell "mkdir /data/local/tmp/recovery"
    $ADBB push busybox /data/local/tmp/recovery
    $ADBB push unin.sh /data/local/tmp/recovery
    $ADBB shell "chmod 755 /data/local/tmp/recovery/busybox"
    $ADBB shell "chmod 755 /data/local/tmp/recovery/unin.sh"
    $ADBB shell "su -c /data/local/tmp/recovery/unin.sh" && sleep 1
    $ADBB shell "rm -r /data/local/tmp/recovery"
	
    if [ $? -eq 0 ]; then
	printf "Uninstall done\n"
    else
        printf "Uninstall failed!\n"
    fi

}

baner

if app_exists adb ; then
    printf "Required adb is installed...\n"
    ADB=adb
    ADBB=$ADB
fi

doAdb

PS3='Enter your choice: '
options=("Install MultiRecovery (Android 4.3/4.4.x/5.1.1)" "Uninstall MultiRecovery" "View xda thread" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install MultiRecovery (Android 4.3/4.4.x/5.1.1)")
            doInstall
            ;;
        "Uninstall MultiRecovery")
            doRemove
            ;;
        "View xda thread")
            openurl 'http://forum.xda-developers.com/xperia-m2/development/d2303-philz-touch-recovery-6-t3047492'
            break
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done

cd ..
$ADB kill-server

