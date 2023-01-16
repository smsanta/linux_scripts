redisenoFolder="/opt/work/projects/ar-bancor-rediseno"
redisenoMobileApkFileName="app-debug.apk"
redisenoMobileFolder=$redisenoFolder"/@app/bancon-cordova"
redisenoMobileAndroidPlatformFolder=$redisenoMobileFolder"/platforms/android"
redisenoMobileApkFolder=$redisenoMobileAndroidPlatformFolder"/app/build/outputs/apk/debug"
redisenoMobileApkFile=$redisenoMobileApkFolder"/"$redisenoMobileApkFileName

echo "Sitting on project folder"
cd /opt/work/projects/ar-bancor-rediseno

#Force delete platform folder if needed.
if [ "$1" = "d" ]; then
  echo "Deleting android platform folder"
  rm $redisenoMobileAndroidPlatformFolder -R
fi

echo "Starting compile app"
npx lerna exec --scope=@app/bancon-cordova -- npm run android:build

echo "Final step showing apk folder or notofy fail"
if [ -f $redisenoMobileApkFile ]; then
  echo "Moving APK file to desktop."
  notify-send "Redisenio APK generation SUCCESS." "APK is now in the Desktop."
  mv $redisenoMobileApkFile ~/Desktop
else
  echo "APK Generation failed?"
  notify-send "Redisenio APK generation FAILED."
fi
