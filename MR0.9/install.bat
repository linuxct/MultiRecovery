@echo off
cls
COLOR A
rem                 __  __       _ _   _                     
rem                |  \/  |     | | | (_)                    
rem                | \  / |_   _| | |_ _                     
rem                | |\/| | | | | | __| |                    
rem                | |  | | |_| | | |_| |                    
rem       _____    |_|  |_|\__,_|_|\__|_|                    
rem      |  __ \                                   
rem      | |__) |___  ___ _____   _____ _ __ _   _ 
rem      |  _  // _ \/ __/ _ \ \ / / _ \ '__| | | |
rem      | | \ \  __/ (_| (_) \ V /  __/ |  | |_| |
rem      |_|  \_\___|\___\___/ \_/ \___|_|   \__, |
rem                                           __/ |
rem                                          |___/ 
echo " ============================================ "
echo " |                                          | "
echo " |    *** MultiRecovery 0.9 Installer ***   | "
echo " |         for Xperia M2 (& M2 Aqua)        | "
echo " |      by Andrej732, LinuxCT, AlexJ        | "
echo " |   Based on NUT's and Rachit Rawat work   | "
echo " |                                          | "
echo " ============================================ "

echo.
echo =================================================
echo    Connect Xperia M2 with USB debugging on ...
echo =================================================

cd files
adb kill-server
adb start-server
adb wait-for-device
echo Device Detected.
echo.

:menu
echo 1. Install MultiRecovery v0.8 (Android 4.3/4.4.x/5.1.1)
echo 2. Uninstall MultiRecovery
echo 3. Exit

SET /P M=Enter your choice:
echo.
IF %M%==1 GOTO multirecovery
IF %M%==2 GOTO remove
IF %M%==3 GOTO end
pause

:multirecovery
echo ===============================================
echo          Installing MultiRecovery ...
echo ===============================================
adb shell "mkdir /data/local/tmp/recovery"
adb push recovery.sh /data/local/tmp/recovery
adb push dummy.sh /data/local/tmp/recovery
adb push twrp/twrp.cpio /data/local/tmp/recovery
adb push philz/philz.cpio /data/local/tmp/recovery
adb push cwm/cwm.cpio /data/local/tmp/recovery
adb push byeselinux/byeselinux.ko /data/local/tmp/recovery
adb push byeselinux/byeselinux.sh /data/local/tmp/recovery
adb push byeselinux/modulecrcpatch /data/local/tmp/recovery
adb push busybox /data/local/tmp/recovery
adb push step3.sh /data/local/tmp/recovery
adb shell "chmod 755 /data/local/tmp/recovery/busybox"
adb shell "chmod 755 /data/local/tmp/recovery/step3.sh"
adb shell "su -c /data/local/tmp/recovery/step3.sh"
adb shell "rm -r /data/local/tmp/recovery"
adb kill-server

echo.
echo Finished!
echo.
goto menu

:remove
echo ===============================================
echo         Uninstalling MultiRecovery ...
echo ===============================================
adb shell "mkdir /data/local/tmp/recovery"
adb push busybox /data/local/tmp/recovery
adb push unin.sh /data/local/tmp/recovery
adb shell "chmod 755 /data/local/tmp/recovery/busybox"
adb shell "chmod 755 /data/local/tmp/recovery/unin.sh"
adb shell "su -c /data/local/tmp/recovery/unin.sh"
adb shell "rm -r /data/local/tmp/recovery"
adb kill-server
echo. 
echo Finished!.
echo.
goto menu

:end
exit
