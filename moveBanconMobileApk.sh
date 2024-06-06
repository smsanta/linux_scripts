#/opt/work/projects/ar-bancor-rediseno/@app/bancon-cordova/platforms/android/app/build/outputs/apk/debug/app-debug.apk
redisenoFolder="/opt/work/projects/ar-bancor-rediseno"
mobileAppDestinyFolder="/home/jsantacruz/Desktop"
redisenoMobileApkFileName="app-debug.apk"
redisenoMobileBackupApkFileName="app-debug-ftw.apk"
redisenoMobileFolder=$redisenoFolder"/@app/bancon-cordova"
redisenoMobileAndroidPlatformFolder=$redisenoMobileFolder"/platforms/android"
redisenoMobileApkFolder=$redisenoMobileAndroidPlatformFolder"/app/build/outputs/apk/debug"
redisenoMobileApkFile=$redisenoMobileApkFolder"/"$redisenoMobileApkFileName
redisenoMobileApkDestinyFile=$mobileAppDestinyFolder"/"$redisenoMobileApkFileName
redisenoMobileApkBackupDestinyFile=$mobileAppDestinyFolder"/"$redisenoMobileBackupApkFileName

if [ -f $redisenoMobileApkDestinyFile ]; then
  if [ -f $redisenoMobileApkBackupDestinyFile ]; then
    echo "Removing older backup. ($redisenoMobileApkBackupDestinyFile)"
    rm $redisenoMobileApkBackupDestinyFile
  fi
  echo "Creating newer apk backup. ($redisenoMobileApkDestinyFile)"
  mv $redisenoMobileApkDestinyFile $redisenoMobileApkBackupDestinyFile
fi

echo "Moving APK file to desktop."

if [ -f $redisenoMobileApkFile ]; then
  notify-send "Redisenio APK." "APK is now in the Desktop."
  mv $redisenoMobileApkFile $mobileAppDestinyFolder
else
  notify-send "Redisenio APK Error." "APK does not exists."
fi
