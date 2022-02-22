#!/bin/bash

emulatorName="$1"
if [ -z $1 ]; then
    emulatorName="PixelXL"
fi

echo "Executing emulator: $emulatorName"

cd /opt/libs/andorid/sdk/emulator

exec ./emulator -avd $emulatorName -accel on

