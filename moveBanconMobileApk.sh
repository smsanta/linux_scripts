################################## VARS ##################################### 
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
#############################################################################
################################## OPTS #####################################
uploadToOptimus=false
# getopts 
# single character a-z means input flag
# character + : 
#  means it should have and input parameter data read from ${OPTARG}
while getopts "ui:" inArgs
do
  case $inArgs in
    u) #Reset Project Setup
      uploadToOptimus=true
    ;;
    i) #Assign param ip
      #placeholder localVar="${OPTARG}"
    ;;
    *)
      echo "No args"
    ;;
  esac
done
#############################################################################

if [ -f $redisenoMobileApkDestinyFile ]; then
  if [ -f $redisenoMobileApkBackupDestinyFile ]; then
    echo "Removing older backup. ($redisenoMobileApkBackupDestinyFile)"
    rm $redisenoMobileApkBackupDestinyFile
  fi
  echo "Creating newer apk backup. ($redisenoMobileApkDestinyFile)"
  cp $redisenoMobileApkDestinyFile $redisenoMobileApkBackupDestinyFile
fi

echo "Moving APK file to desktop."

if [ -f $redisenoMobileApkFile ]; then
  notify-send "Redisenio APK." "APK is now in the Desktop."
  cp $redisenoMobileApkFile $mobileAppDestinyFolder
  
  if [ "$uploadToOptimus" = true ]; then
    curl --upload-file $redisenoMobileApkDestinyFile  -u 'WORKGROUP\smsanta:mumirs89' smb://192.168.2.1/opt/
    notify-send "Redisenio APK." "APK is now in Optimus Server."
  fi
  
else
  notify-send "Redisenio APK Error." "APK does not exists."
fi
