#!/bin/bash

############################### METHODS #####################################
#Replaces a text in a file
ReplaceText(){
    #Parameters:
    toBeReplaced="$1"
    replaceText="$2"
    filePath="$3"

    echo "Replacing > $toBeReplaced ||| For > $replaceText ||| In file: $filePath"
    sed -i "s+$toBeReplaced+$replaceText+g" $filePath
}
                     

ResetProject(){
    echo ""
    echo "<<< Cleaning an setting branch to HEAD >>>"
    cd $redisenoFolder
    git reset HEAD --hard && git clean -f -d

    echo "<<< ||| >>>"
}

GetCurrentBranchName(){
  echo "$(git rev-parse --abbrev-ref HEAD)"
}

UpdateProject(){
  cd $redisenoFolder
  currentBranch=$(GetCurrentBranchName)
  ResetProject
  git pull origin $currentBranch
}

ModifyInternalParameter(){
  #Parameters:
  parameterName="$1"
  parameterCurrentValue="$2"
  parameterNewValue="$3"
  
  sedToBeReplaced="$parameterName=\"$parameterCurrentValue\""
  sedNewValueOverride="$parameterName=\"$parameterNewValue\""
  
  ReplaceText $sedToBeReplaced $sedNewValueOverride $0
}

SelfSetup(){
    echo ""
    echo "First run, running self setup, you will be ask to setup 4 variables."
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
    read -p "4- Tell me the gradle java home path(Ej: /home/jsantacruz/.sdkman/candidates/java/11.0.20-librca): " gradleHome
    echo ""
    
    echo "####################################################################"
    echo ""

    echo "Script project path now is:        $projectPath"
    echo "Script mobile project path now is: $evolutiveLocalHost" 
    echo "Script local ip now is:            $evolutiveIntranetHost" 
    echo "Script Gradle home is:             $gradleHome" 
    echo ""

    ModifyInternalParameter "redisenoFolder" $redisenoFolder $projectPath
    ModifyInternalParameter "localEvolutiveLocalhostIp" $localEvolutiveLocalhostIp $evolutiveLocalHost
    ModifyInternalParameter "localEvolutiveIntranetHttpsIp" $localEvolutiveIntranetHttpsIp $evolutiveIntranetHost
    ModifyInternalParameter "localGradleJavaHomeValue" $localGradleJavaHomeValue $gradleHome
    ModifyInternalParameter "lastPath" $lastPath $currentPath
    
    echo "Self setup is DONE!! Please run me again!"
    echo "(If something went wrong have can be manually change later on or re-run this script by using -s parameter.)"
    echo ""
    exit 0
}
#############################################################################

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

localEvolutiveLocalhostIp="localhost:8088"
localEvolutiveIntranetHttpsIp="192.168.2.7:8089"
localCordovaConfigIp="value=\"$localEvolutiveIntranetHttpsIp"
localGradleJavaHomeValue="/home/jsantacruz/.sdkman/candidates/java/11.0.20-librca"
localGradleJavaHome="$defaultGradleJavaHome$localGradleJavaHomeValue"
#############################################################################

########################### Internal Setup ##################################
lastPath="/home/jsantacruz/devCommands"
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

################################## OPTS ##################################### 
while getopts "srui:" inArgs
do
  case $inArgs in
    s) #Run Setup
      SelfSetup
    ;;
    r) #Reset Project Setup
      ResetProject
    ;;
    u) #Reset & pull current branch updates
      UpdateProject
    ;;
    i) #Assign param ip
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
ReplaceText $defaulEnvIp $localEvolutiveLocalhostIp $envFile

#Set .env.production file
ReplaceText $defaulEnvProdIpApi $localEvolutiveIntranetHttpsIp $envProdFile
ReplaceText $defaulEnvProdIpFront $localEvolutiveIntranetHttpsIp $envProdFile

#Set cordova config.xml file
ReplaceText $defaultCordovaConfigIp $localCordovaConfigIp $cordovaConfigFile

#Set cordova gradle.properties file
ReplaceText $defaultGradleJavaHome $localGradleJavaHome $cordovaGradleFile
echo "<<< ||| >>>"
echo ""

cd $redisenoFolder
git status