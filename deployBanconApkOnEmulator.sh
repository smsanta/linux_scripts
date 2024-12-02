
################################## VARS ##################################### 
#Folders
redisenoFolder="/opt/work/projects/ar-bancor-rediseno"
apkCompiledFolder="$redisenoFolder/@app/bancon-cordova/platforms/android/app/build/outputs/apk/debug"
apkName="app-debug.apk"
apkFilePath="$apkCompiledFolder/$apkName"
androidSDK="$ANDROID_SDK_ROOT"
androidSDKPlatformTools="$androidSDK/platform-tools"
################################## OPTS ##################################### 
targetEmulator=""
# getopts 
# single character a-z means input flag
# character + : 
#  means it should have and input parameter data read from ${OPTARG}
while getopts "s:a:" inArgs
do
  case $inArgs in
    s) #Target emulator
      targetEmulator="-s ${OPTARG}"
    ;;
    a) #Target apk file
      apkFilePath="${OPTARG}"
    ;;
    *)
      echo "No args"
    ;;
  esac
done
####################################################################

cd $androidSDKPlatformTools
./adb install -r $apkFilePath $targetEmulator