#!/bin/bash

set -e

LOCAL_DIR=`dirname $0`
LOCAL_NAME=adb
ADB=${LOCAL_DIR}/${LOCAL_NAME}
ADBB=../$ADB

adb_exists ()
{
    type "$1" &> /dev/null ;
}

function baner ()
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

function doAdb ()
{
    $ADB kill-server
    $ADB start-server
    $ADB wait-for-device
    cd files
}

function doInstall ()
{
    printf "===============================================\n"
    printf "          Installing MultiRecovery             \n"
    printf "===============================================\n\n"
        
    $ADBB shell "mkdir /data/local/tmp/recovery"
    $ADBB push recovery.sh /data/local/tmp/recovery
    $ADBB push script.sh /data/local/tmp/recovery
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
	printf "Thank you for installing your MultiRecovery \nEnjoy...\n"
    else
        printf "Installation failed!\n"
        exit 1;
    fi

}

function doRemove ()
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
	printf "Uninstalling done\n"
    else
        printf "Uninstalling failed!\n"
        exit 1;
    fi

}

baner

if adb_exists adb ; then
    printf "Required adb is installed..."
    ADB=adb
    ADBB=$ADB
fi

doAdb

PS3='Enter your choice: '
options=("Install MultiRecovery v0.8 (Android 4.3/4.4.x/5.1.1)" "Uninstall MultiRecovery" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install MultiRecovery v0.8 (Android 4.3/4.4.x/5.1.1)")
            doInstall
            ;;
        "Uninstall MultiRecovery")
            doRemove
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done

cd ..
$ADB kill-server
