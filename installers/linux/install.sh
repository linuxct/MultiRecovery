#!/bin/bash

set -e

LOCAL_DIR=`dirname $0`
LOCAL_NAME=adb
ADB=${LOCAL_DIR}/${LOCAL_NAME}
ADBB=../$ADB
#ADB=${ADB:-adb}


function baner()
{
	printf "**  MultiRecovery Installer for Xperia M2 LB devices  **\n"
	printf "**         By Rachit Rawat, [NUT]                     **\n"
	printf "**   Modified by LinuxCT, Andrej732, AleksJ           **\n"

	printf "========================================================\n"
	printf "      Connect Xperia M2 with USB debugging on ...       \n"
	printf "========================================================\n"
}

function doAdb()
{
	$ADB kill-server
	$ADB start-server
	$ADB wait-for-device
	cd files
}

function doInstall()
{
	printf "===============================================\n"
	printf "          Installing MultiRecovery\n           \n"
        printf "===============================================\n"
        
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
	    printf "Thank you for installing your MultiRecovery v0.8\nEnjoy...\n"
        else
            printf "Installation failed!\n"
        fi        
            
}

function doRemove()
{
	printf "===============================================\n"
	printf "         Uninstalling MultiRecovery\n          \n"
	printf "===============================================\n"
	
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
        fi        
	
}

baner
doAdb

PS3='Please enter your choice: '
options=("Install MultiRecovery v0.8 (Android 4.3/4.4.x/5.1.1) 1" "Uninstall MultiRecovery 2" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install MultiRecovery v0.8 (Android 4.3/4.4.x/5.1.1) 1")
            doInstall           
            ;;
        "Uninstall MultiRecovery 2")
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

