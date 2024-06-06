#!/bin/bash
sdkEmulatorPath="/opt/libs/android/sdk/emulator"
emulatorName="$1"
if [ -z $1 ]; then
    emulatorName="Pixel2"
fi

echo "Executing emulator: $emulatorName"

cd $sdkEmulatorPath

exec ./emulator -avd $emulatorName -no-snapshot -no-boot-anim 
#./emulator -avd Pixel2 -no-snapshot -no-boot-anim -wipe-data #-accel on
