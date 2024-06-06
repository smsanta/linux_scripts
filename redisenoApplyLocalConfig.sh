#!/bin/bash

############################### METHODS #####################################
#Replaces a text in a file
replaceText(){
    #Parameters:
    filePath="$1"
    toBeReplaced="$2"
    replaceText="$3"

    echo "Replacing > $toBeReplaced ||| For > $replaceText ||| In file: $filePath"
    sed -i "s+$toBeReplaced+$replaceText+g" $filePath
}

resetProject(){
    echo ""
    echo "<<< Cleaning an setting branch to HEAD >>>"
    cd $redisenoFolder
    git reset HEAD --hard && git clean -f -d

    echo "<<< ||| >>>"
}

SelfSetup(){
    echo ""
    echo "First run, running self setup, you will be ask to setup 3 variables."
    echo "####################################################################"
    echo ""
    echo "Before start setting things up there is an example of how there variables might look like."
    echo ""
    echo "####################################################################"
    echo ""
    read -p "1- Tell me the path to ar-bancor-rediseno project (Ej: /opt/work/projects/ar-bancor-rediseno): " projectPath
    echo ""
    read -p "2- Tell me the evolutive localhost ip (Ej: localhost:8088): " evolutiveLocalHost
    echo ""
    read -p "3- Tell me the evolutive intranet ip (Ej: 192.168.2.7:8089): " evolutiveIntranetHost
    echo ""
    echo "####################################################################"
    echo ""

    echo "Script project path now is:        $projectPath"
    echo "Script mobile project path now is: $evolutiveLocalHost" 
    echo "Script default local ip now is:    $evolutiveIntranetHost" 

    echo ""
    sed -i "s+$redisenoFolder+$projectPath+g" $0
    sed -i "s+$localEvolutiveLocalhostIp+$evolutiveLocalHost+g" $0
    sed -i "s+$localEvolutiveIntranetHttpsIp+$evolutiveIntranetHost+g" $0
    sed -i "s+lastPath='$lastPath'+lastPath='$currentPath'+g" $0

    echo "Self setup is DONE!! Please run me again!"
    echo "(If something went wrong have can be manually change later on or re-run this script by using -s parameter.)"
    echo ""
    exit 0
}
#############################################################################

########################### Internal Setup ##################################
lastPath='/home/jsantacruz/devCommands'
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

################################## VARS ##################################### 
#Folders
redisenoFolder="/opt/work/projects/ar-bancor-rediseno"
ommnichannelFolder="$redisenoFolder/@app/bancor-omnichannel"

#Files
envFile="$redisenoFolder/.env"
envProdFile="$redisenoFolder/.env.production"
cordovaConfigFile="$redisenoFolder/@app/bancon-cordova/config.xml"
cordovaGradleFile="$redisenoFolder/@app/bancon-cordova/res/android/gradle.properties"

#Data
defaulEnvIp="localhost:8085"
defaulEnvProdIpApi="bancor-qa-api-rd.technisys.net"
defaulEnvProdIpFront="bancor-qa-rd.technisys.net"
defaultCordovaConfigIp="value=\"bancor-dev-vu-fraud2-api.technisys.net"
defaultGradleJavaHome="org.gradle.java.home="

localEvolutiveLocalhostIp="localchost:9999"
localEvolutiveIntranetHttpsIp="199.198.197.196:8881"
localCordovaConfigIp="value=\"$localEvolutiveIntranetHttpsIp"
localGradleJavaHome="$defaultGradleJavaHome/home/jsantacruz/.sdkman/candidates/java/11.0.20-librca"
#############################################################################

################################## OPTS ##################################### 
while getopts "sri:" inArgs
do
  case $inArgs in
    s) #Run Setup
      SelfSetup
    ;;
    r)
      resetProject
    ;;
    i)
      localEvolutiveIntranetHttpsIp="${OPTARG}"
    ;;
    *)
      echo "No args"
    ;;
  esac
done
####################################################################

#Apply changes to files
echo ""
echo "<<< Applying Changes to files >>>"

#Set .env file
replaceText $envFile $defaulEnvIp $localEvolutiveLocalhostIp

#Set .env.production file
replaceText $envProdFile $defaulEnvProdIpApi $localEvolutiveIntranetHttpsIp
replaceText $envProdFile $defaulEnvProdIpFront $localEvolutiveIntranetHttpsIp

#Set cordova config.xml file
replaceText $cordovaConfigFile $defaultCordovaConfigIp $localCordovaConfigIp

#Set cordova gradle.properties file
replaceText $cordovaGradleFile $defaultGradleJavaHome $localGradleJavaHome
echo "<<< ||| >>>"
echo ""

cd $redisenoFolder
git status