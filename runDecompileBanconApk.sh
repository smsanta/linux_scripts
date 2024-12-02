#!/bin/sh
apkToolFolder="/opt/work/libs/android/apktool"
targetApkPath="/home/jsantacruz/Desktop/app-debug.apk"
targetDecompileFolder="/home/jsantacruz/Desktop/app-debug-reversed"
echo "Decompiling apk: $targetApkPath"
cd $apkToolFolder
./apktool d $targetApkPath -o $targetDecompileFolder -f

echo "Sources demcompiled in folder: $targetDecompileFolder"
nautilus $targetDecompileFolder &