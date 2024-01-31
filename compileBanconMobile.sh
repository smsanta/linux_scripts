#!/bin/bash
scriptVersion=1.1.2

############################### CRITICAL FOLDERS AND IP SETUP ##################################### 
#This are only variables that must be modified if want to be used on another pc.
ommnichannelFolder="/opt/work/projects/ar-bancor-omnichannel" # Path to "ar-bancor-omnichannel" project.
ommnichannelMobileTmpCompileFolder="/opt/work/projects/bancon-mobile" # Path to the temp folder where the APK will be generated.
ommnichannelDefaultLocalIpApplicationListening="192.168.2.90:8088" # Local IP Where our test APK is going to connect if no args.
###################################################################################################

############################### STATIC VARS #####################################
#Subfolders locations
ommnichannelMobileFolder=$ommnichannelFolder"/mobile/phonegapGenerator"
ommnichannelCompiledMobileFolder=$ommnichannelMobileFolder"/_zip_to_build"
ommnichannelUnzipedMobileSourcesFolder=$ommnichannelCompiledMobileFolder"/app"
ommnichannelMobileTmpAppCompileFolder=$ommnichannelMobileTmpCompileFolder"/app"
ommnichannelMobileTmpAppBuildGradleFile=$ommnichannelMobileTmpAppCompileFolder"/platforms/android/build.gradle"
ommnichannelMobileTmpAppApkFolder=$ommnichannelMobileTmpAppCompileFolder"/platforms/android/app/build/outputs/apk/debug"
ommnichannelMobileApkFileName="app-debug.apk"
ommnichannelMobileApkFile=$ommnichannelMobileTmpAppApkFolder"/"$ommnichannelMobileApkFileName

ommnichannelDefaultSourceLocalIpApplicationListening="http://192.168.0.108:8080" #This ip must match with the one in the sources (This m8 never be changed)
autoIpSuffix="auto="
####################################################################

##################################### Utility Functions ###########################################
ShowHelp(){
  echo ""
  echo "Script for bulding bancon mobile APK - Version: $scriptVersion"
  echo ""
  echo "This script need to have configured 3 main variables that have to be adjusted"
  echo "The first time it runs will promt to setup those variables"
  echo "By default the script is set to generate the local testing DEV version"
  echo "Eg. Executing this script without parameter implicit equals to: "
  echo "    sh $0"
  echo "    sh $0 -i $ommnichannelDefaultLocalIpApplicationListening -e DEV -p com"
  echo ""
  echo "Questions, suggestions or report a bug to mailto:jsantacruz@bancor.com.ar<Juan Ignacio Santa Cruz>"
  echo ""
  echo "Arguments" 
  echo ""
  echo "   -h, Show help information"
  echo ""
  echo "   -s, Runs initial setup."
  echo ""
  echo "   -i <IP:PORT>, Sets the ip where the dev APK is going to connect. Only work for app-debug (-e DEV -p com)"
  echo "       Supported values are as follows"
  echo "       Option 1 - IP and port is required > $0 -i 192.168.1.1:8080 <"
  echo "       Option 2 - If you have dynamic ip it can be auto detected it by indicating it as auto and then networkd interface and port"
  echo "                  Eg. The value should be submitted with this pattern '<auto>=<interface>=<port>' >> $0 -i auto=eth0=8080"
  echo ""
  echo "   -p <PACKAGE>, Sets the package name to be used as anchor for finding he correct ZIP source generated after builApp.sh"
  echo "       Possible values 'com | ar | (if none match) Argument value '"
  echo "       com -> Stands for 'com.technisys.bancor'"
  echo "       ar  -> Stands for 'ar.com.bancor.bancon'"
  echo "       *  -> If none of these match the literal value is used"
  echo ""
  echo "   -e <ENVIRONMENT>, Sets the environment version of the ZIP that should be generate the APK for"
  echo "       Possible values 'DEV | DEV-prd | PRE-PROD | PROD | TEST | TEST-prd '"
  echo "       "
  echo "       (Note: Arguments 'p' and 'e' are usually married the summation of both should match one of the ZIP files generated)"
  echo ""
  echo "   -r, Clear all the changes in the branch after generated the apk."
  echo "       IMPORTANT: this will WIPE all the changes and sets the branch to the HEAD commit"
  echo ""
  echo "   -l, This param will include mavenLocal() to the build.gradle in the cordova application"
  echo "       that is used when gradle cannot resolve some of the dependences and in that case we can "
  echo "       'hand made' add those to the local repository. Check the following script for that case"
  echo "       Eg: mvn install:install-file -Dfile=/path/to/arr/file/dependency/vuonboardingsdk-1.9.9.45.aar -DgroupId=com.vusecurity -DartifactId=vuonboardingsdk -Dversion=1.9.9.45 -Dpackaging=aar"
  echo ""
  
  exit 0
}

SelfSetup(){
    echo ""
    echo "First run, running self setup, you will be ask to setup 3 variables."
    echo "####################################################################"
    echo ""
    echo "Before start setting things up there is an example of how there variables might look like."
    echo ""
    echo "1- Tell me the path to ar-bancor-omnichannel project: /opt/work/projects/ar-bancor-omnichannel"
    echo "2- Tell me the path where the temporary mobile project folder will be: /opt/work/projects/bancon-mobile"
    echo "3- Tell me your local ip(If you have dynamic ip it can be set with param -i when running the script later on): 192.168.1.10:8080"
    echo "   (If you have dynamic ip you can set it to auto with the this value instead of an ip (asuming your main network adapter is eth0) ==> auto=eth0=8080)"
    echo ""
    echo "####################################################################"
    echo ""
    read -p "1- Tell me the path to ar-bancor-omnichannel project: " projectPath
    echo ""
    read -p "2-  Tell me the path where the temporary mobile project folder will be: " mobilePath
    echo ""
    read -p "3- Tell me your local ip(If you have dynamic ip it can be set with param -i when running the script later on): " localIp
    echo ""
    echo "####################################################################"
    echo ""

    echo "Script project path now is:        $projectPath"
    echo "Script mobile project path now is: $mobilePath" 
    echo "Script default local ip now is:    $localIp" 

    echo ""
    sed -i "s+$ommnichannelFolder+$projectPath+g" $0
    sed -i "s+$ommnichannelMobileTmpCompileFolder+$mobilePath+g" $0
    sed -i "s+$ommnichannelDefaultLocalIpApplicationListening+$localIp+g" $0
    sed -i "s+lastPath='$lastPath'+lastPath='$currentPath'+g" $0

    echo "Self setup is DONE!! Please run me again!"
    echo "(If something went wrong have can be manually change later on or re-run this script by using -s parameter.)"
    echo ""
    exit 0
}

CleanChanges(){
    while true; do
      echo ""
      echo ""

      cd $ommnichannelFolder
      git status

      read -p "Esta por eliminar todos los cambios al branch, y volver al ultimo commit, desea continuar? Y/n: " yn
      case $yn in
        [Yy]*)
          rm $ommnichannelCompiledMobileFolder -R
          git reset HEAD --hard 
          git clean -f -d
          break
        ;;
        [Nn]*) 
          exit 0
        ;;
        *) 
          echo "Debes responder Si(Y) o No(n)."
        ;;
      esac
    done
}

GetCurrentIpFromInterface(){
  echo $(ifconfig $1 | awk -F ' *|:' '/inet /{print $3}')
}

GetApplicationUrlListening(){
  finalIp=""
  
  if echo $1 | grep -q "$autoIpSuffix"; then
    
    desiredInterface=""
    desiredPort=""

    interfaceAndPort="${1##*auto=}"

    interfaces=$(echo $interfaceAndPort | tr "=" " ")

    for interface in $interfaces; do
      if [ -z "$desiredInterface" ]; then
        desiredInterface=$interface
      else
        desiredPort=$interface
      fi
    done

    desiredUrl=$( GetCurrentIpFromInterface $desiredInterface )

    finalIp="$desiredUrl:$desiredPort"
  else
    finalIp="$1"
  fi 

  echo "http://$finalIp"
}

Announce() {
    echo "################# $1"
}

DrawSeparatorLine(){
  echo "####################################################################"
}

throwError(){
  echo ""
  echo "ERROR!!! - $1"
  echo ""
  echo "Exiting"
  exit 1
}
###################################################################################################

############################### Args ##################################### 
ommnichannelLocalIpApplicationListening=$( GetApplicationUrlListening "$ommnichannelDefaultLocalIpApplicationListening" ) # Local IP Where the dev APK is going to connect.
omnichannelZipNamePackage="com.technisys.bancor" #Possible values "com | ar | (if none match) Argument value "
omnichannelZipNameEnvironment="DEV" #Possible values "DEV | DEV-prd | PRE-PROD | PROD | TEST | TEST-prd "
cleanBranchChanges=false
useMavenLocal=false

while getopts "hsi:e:p:lr" inArgs
do
  case $inArgs in
    h) #Help 
      ShowHelp
    ;;
    s) #Run Setup
      SelfSetup
    ;;
    i) #IP Listening
      ommnichannelLocalIpApplicationListening=$( GetApplicationUrlListening "${OPTARG}" )
    ;;
    p) #ZIP Package
      if [ ${OPTARG} = "com" ]; then
        omnichannelZipNamePackage="com.technisys.bancor"
      elif [ ${OPTARG} = "ar" ]; then
        omnichannelZipNamePackage="ar.com.bancor.bancon"
      else 
        omnichannelZipNamePackage=${OPTARG}
      fi
    ;; 
    e) #Environment
      omnichannelZipNameEnvironment=${OPTARG}
    ;;
    l)
      useMavenLocal=true
    ;;
    r)
      cleanBranchChanges=true
    ;;
    *)
      throwError "Invalid Argument provided."
    ;;
  esac
done
####################################################################

################################# Internal Setup & and vars #######################################
lastPath='/home/juan/devCommands'
currentPath=""

currentPathDir=$(dirname "$0")
currentPathPwd=$(pwd)

scriptFileName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
scriptFilePath=${currentPathDir%"$filename"}

if [ -z "${scriptFilePath##*.}" ]; then
  currentPath=$currentPathPwd
else
  currentPath="$(cd $currentPathDir; pwd)"
fi

if [ "$lastPath" != "$currentPath" ]; then 
    echo "Starting Script Initial Setup..."
    SelfSetup
fi

###################################################################################################

############################### SHOW VARS #####################################
DrawSeparatorLine
Announce "Omnichannel Mobile compiler data"
Announce "Var ommnichannelFolder: $ommnichannelFolder"
Announce "Var ommnichannelMobileFolder: $ommnichannelMobileFolder"
Announce "Var ommnichannelCompiledMobileFolder: $ommnichannelCompiledMobileFolder"
Announce "Var ommnichannelMobileTmpCompileFolder: $ommnichannelMobileTmpCompileFolder"
Announce "Var ommnichannelMobileTmpAppCompileFolder: $ommnichannelMobileTmpAppCompileFolder"
Announce "Var ommnichannelLocalIpApplicationListening: $ommnichannelLocalIpApplicationListening"
Announce "Var omnichannelZipNamePackage $omnichannelZipNamePackage"
Announce "Var omnichannelZipNameEnvironment: $omnichannelZipNameEnvironment"
Announce "Var useMavenLocal: $useMavenLocal"
Announce "Var cleanBranchChanges: $cleanBranchChanges"
DrawSeparatorLine
####################################################################

############################# CLEANING #######################################
Announce "Cleaning Working Folders"

Announce "Cleaning 1/2 - $ommnichannelCompiledMobileFolder"
if [ -d $ommnichannelCompiledMobileFolder ]; then
  rm $ommnichannelCompiledMobileFolder -R
fi

Announce "Cleaning 2/2 - $ommnichannelMobileTmpCompileFolder"
if [ -d $ommnichannelMobileTmpCompileFolder ]; then
  rm $ommnichannelMobileTmpCompileFolder -R
fi
mkdir $ommnichannelMobileTmpCompileFolder
####################################################################

############################### BUILD APP #####################################
cd $ommnichannelMobileFolder
Announce "Resetting and Updating config.xml to point to our local ip address"
git checkout $ommnichannelMobileFolder/config.xml
sed -i 's+'$ommnichannelDefaultSourceLocalIpApplicationListening'+'$ommnichannelLocalIpApplicationListening'+g' config.xml

DrawSeparatorLine
Announce "Starting Building app"
sh buildApp.sh > /dev/null

Announce "App build finished"
####################################################################

################################ PREPARE CORDOVA TMP APP ####################################
DrawSeparatorLine
dotZipSources=$(find $ommnichannelCompiledMobileFolder -name "$omnichannelZipNamePackage*" | grep -E "[0-9]+\.[0-9][0-9]+\.[0-9]+\-$omnichannelZipNameEnvironment-new.zip$")

Announce "App build sources zip file are located in: $dotZipSources"
Announce "Unzziping $dotZipSources"
cd $ommnichannelCompiledMobileFolder

if [ ! -f "$dotZipSources" ]; then
    throwError "Could not find the zip file containing the mobile sources application."
fi

unzip $dotZipSources > /dev/null

Announce "Moving sources to temp folder for compile."
mv $ommnichannelUnzipedMobileSourcesFolder $ommnichannelMobileTmpCompileFolder
DrawSeparatorLine
####################################################################

############################## COMPILE CORDOVA APP ######################################

cd $ommnichannelMobileTmpAppCompileFolder
Announce "cd $ommnichannelMobileTmpAppCompileFolder"

Announce "Setting node to version 14.3.0"
#Source nvm for shell script.
. ~/.nvm/nvm.sh
. ~/.profile
. ~/.bashrc

nvm use 14.15.3

Announce "Check NPM Version (Should be 6.14.9)"
npm -v

Announce "Installing cordova@9.0.0"
npm install cordova@9.0.0

Announce "Adding cordova platform to sources."
npx cordova platform add android@9.0.0

Announce "Finished Cordova platform add."
DrawSeparatorLine

Announce "Building Android APK."

if [ "$useMavenLocal" = true ]; then
  Announce "Including mavenLocal() into build.gradle. File: $ommnichannelMobileTmpAppBuildGradleFile"
  sed -i '/jcenter.*/a mavenLocal()' $ommnichannelMobileTmpAppBuildGradleFile
fi

npx cordova build android
Announce "Finished Cordova build andorid."
DrawSeparatorLine

Announce "Finished - Android APK should be created."
DrawSeparatorLine

if [ -f $ommnichannelMobileApkFile ]; then
  echo "Moving APK file to desktop."
  notify-send "Evolutive APK generation SUCCESS." "APK is now in the Desktop."
  mv $ommnichannelMobileApkFile ~/Desktop
else
  echo "APK Generation failed?"
  notify-send "Evolutive APK generation FAILED."
fi
####################################################################