#!/system/bin/sh

function baner(){
echo " ============================================ "
echo " |           __  __       _ _   _           | "
echo " |          |  \/  |     | | | (_)          | "
echo " |          | \  / |_   _| | |_ _           | "
echo " |          | |\/| | | | | | __| |          | "
echo " |          | |  | | |_| | | |_| |          | "
echo " | _____    |_|  |_|\__,_|_|\__|_|          | "
echo " ||  __ \                                   | "
echo " || |__) |___  ___ _____   _____ _ __ _   _ | "
echo " ||  _  // _ \/ __/ _ \ \ / / _ \ '__| | | || "
echo " || | \ \  __/ (_| (_) \ V /  __/ |  | |_| || "
echo " ||_|  \_\___|\___\___/ \_/ \___|_|   \__, || "
echo " |                                     __/ || "
echo " |                                    |___/ | "
echo " ============================================ "
echo " |                                          | "
echo " |    *** MultiRecovery 0.8 Installer ***   | "
echo " |         for Xperia M2 (& M2 Aqua)        | "
echo " |      by AlexJ, Andrej732 & LinuxCT       | "
echo " |   Based on NUT's and Rachit Rawat work   | "
echo " |                                          | "
echo " ============================================ "
}

function getDeviceProperties(){
	mkdir /data/local/tmp/recovery
	cp MultiRecovery/busybox /data/local/tmp/recovery
	chmod 755 /data/local/tmp/recovery/busybox
	BUSYBOX=/data/local/tmp/recovery/busybox
	VER=$(${BUSYBOX} awk -F= '/ro.build.version.release/{print $NF}' /system/build.prop)
	CUST=$(${BUSYBOX} awk -F= '/ro.semc.version.cust/{print $NF}' /system/build.prop)
	COMPVER=$(${BUSYBOX} awk -F= '/ro.build.id/{print $NF}' /system/build.prop)
	DISPLAYID=$(${BUSYBOX} awk -F= '/ro.build.display.id/{print $NF}' /system/build.prop)
	MODEL=$(${BUSYBOX} awk -F= '/ro.product.model/{print $NF}' /system/build.prop)
	LOWRAM=$(${BUSYBOX} awk -F= '/ro.config.low_ram/{print $NF}' /system/build.prop)
	MINFREC=$(${BUSYBOX} awk -F= '/ro.min_freq_0/{print $NF}' /system/build.prop)
	SEMCMODEL=$(${BUSYBOX} awk -F= '/ro.semc.product.device/{print $NF}' /system/build.prop)
	echo "\nTesting if device is applicable to install MultiRecovery..."
	${BUSYBOX} sleep 3
	if [[ "$0" == "install_debug.sh" ]]; then
		echo "\nAndroid Version installed:"
		echo ${VER}
		echo " "
		echo "SEMC Customization version installed:"
		echo ${CUST}
		echo " "
		echo "Compilation installed:"
		echo ${COMPVER}
		echo " "
		echo "Compilation showed:"
		echo ${DISPLAYID}
		echo " "
		echo "Model:"
		echo ${MODEL}
		echo " "
		echo "Device family:"
		echo ${SEMCMODEL}
		echo " "
		echo "LowRam enabled:"
		echo ${LOWRAM}
		echo " "
		echo "CPU minimal frecuency:"
		echo ${MINFREC}
		echo "\n\n"
	fi
	if [ "${SEMCMODEL}" != "D23" ] && [ "${SEMCMODEL}" != "D24" ]; then 
		echo "INVALID DEVICE. Exiting."
		rm -r /data/local/tmp/recovery
		exit 1
	fi
	echo "Device Valid. Continuing.\n"
	${BUSYBOX} sleep 2
	rm -r /data/local/tmp/recovery
}

function doCD(){
	cd MultiRecovery
}

function doInstall(){
	echo "\n============================"
	echo "Installing MultiRecovery"
    echo "============================"
        
	mkdir /data/local/tmp/recovery
	cp recovery.sh /data/local/tmp/recovery
	cp script.sh /data/local/tmp/recovery
	cp twrp/twrp.cpio /data/local/tmp/recovery
	cp philz/philz.cpio /data/local/tmp/recovery
	cp cwm/cwm.cpio /data/local/tmp/recovery
	cp byeselinux/byeselinux.ko /data/local/tmp/recovery
	cp byeselinux/byeselinux.sh /data/local/tmp/recovery
	cp byeselinux/modulecrcpatch /data/local/tmp/recovery
	cp busybox /data/local/tmp/recovery
	cp step3.sh /data/local/tmp/recovery
	chmod 755 /data/local/tmp/recovery/busybox
	chmod 755 /data/local/tmp/recovery/step3.sh
	su -c /data/local/tmp/recovery/step3.sh
	rm -r /data/local/tmp/recovery
	
	if [ $? -eq 0 ]; then
	    echo "\nThank you for installing your MultiRecovery v0.8"
		echo "Enjoy...\n"
        else
            echo "\nInstallation failed!\n"
        fi        
            
}

function doRemove(){
	echo "\n============================"
	echo "Uninstalling MultiRecovery"
	echo "============================"
	
	mkdir /data/local/tmp/recovery
	cp busybox /data/local/tmp/recovery 
	cp unin.sh /data/local/tmp/recovery
	chmod 755 /data/local/tmp/recovery/busybox
	chmod 755 /data/local/tmp/recovery/unin.sh
	su -c /data/local/tmp/recovery/unin.sh
	rm -r /data/local/tmp/recovery
	
	if [ $? -eq 0 ]; then
	    echo "\nUninstalling done\n"
        else
            echo "\nUninstalling failed!\n"
        fi        
	
}

getDeviceProperties
baner
doCD

PS3='Please enter your choice: '
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
        *) echo Invalid option, choose from 1 to 3;;
    esac
done

cd ..

