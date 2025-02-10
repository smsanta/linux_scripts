#!/bin/bash
scriptVersion=1.0.1

################################## VARS ##################################### 
omnichannelFolder="/opt/work/projects/ar-bancor-rediseno/@app/bancor-omnichannel"
omnichannelApiPom="$omnichannelFolder/api/pom.xml"
connectorFolder="$omnichannelFolder/connector"
m2Folder="/home/jsantacruz/.m2"
m2BanconConnectorFolder=$m2Folder"/repository/ar-bancor"
moveGeneratedConnectorPath="/tmp/connector"

#############################################################################
################################## OPTS #####################################
runShowHelp=false
runFirstSetup=false
connectorName=""
promptConnectorName=true
connectorTargetVersion=""
cleanBranchChanges=false
addConnectorTolocalMaven=false
moveGeneratedConnector=false

# getopts 
# single character a-z means input flag
# character + : 
#  means it should have and input parameter data read from ${OPTARG}
while getopts "hHsric:v:mM:" inArgs
do
  case $inArgs in
    [hH])
      #Help  
      runShowHelp=true
    ;;
    s) 
      #Run Self Setup
      runFirstSetup=true
    ;;
    r)
      #Fully cleans the project to the last commit 
      cleanBranchChanges=true
    ;;
    c)
      #Assign param connectorName 
      connectorName="${OPTARG}"
      promptConnectorName=false
    ;;
    v)
      #Connector Version  
      connectorTargetVersion="${OPTARG}"
    ;;
    i)
      #Internal - Add depencies to local maven 
      addConnectorTolocalMaven=true
    ;;
    [mM])
      moveGeneratedConnector=true
      #Move Generated connector
      if [ ! -z "${OPTARG}" ]; then
        moveGeneratedConnectorPath="${OPTARG}"
      fi
    ;;
    *)
      echo "Invalid args"
      exit 1
    ;;
  esac
done
#############################################################################
############################### FUNCTIONS ###################################
TRUE() {
  return 0;
}

FALSE() {
  return 1;
}

EXIT(){
  if [ ! -z "$1" ]; then
    echo $1
  fi

  exit $(TRUE)
}

EXIT_ERROR(){
  if [ ! -z "$1" ]; then
    echo $1
  fi

  exit $(FALSE)
}

DrawSeparatorLine(){
  echo ""
  echo "####################################################################"
  echo "####################################################################"
  echo "####################################################################"
  echo ""
}

CleanChanges(){
    while true; do
      echo ""
      echo ""

      cd $omnichannelFolder
      git status

      AskParameter "Esta por eliminar todos los cambios al branch, y volver al ultimo commit, desea continuar? Y/n: " yn
      case $yn in
        [Yy]*)
          git reset HEAD --hard 
          git clean -f -d
          break
        ;;
        [Nn]*) 
          EXIT
        ;;
        *) 
          echo "Debes responder Si(Y) o No(n)."
        ;;
      esac
    done
}

#Ask a parameter to the user and sets the named variable also validates correct options
#if the first correct option is "*" it will allow empty values
#Eg with validations: 
#AskParameter "Say anumber between 1 and 3" askedNumber "1" "2" "3"
AskParameter(){
    local promt=$1
    shift
    local storeVar=$1
    shift
    local validOptions=("$@")
    
    while true; do
      echo ""

      read -p "$promt" "$storeVar"
      
      local storedVarValue="${!storeVar}"
      if [[ ! -z "${validOptions[0]}" && ! "${validOptions[0]}" == "*" ]]; then
          if IsTextInArray $storedVarValue $validOptions; then
            break
          fi

          echo "El valor ingresado -$storedVarValue- no es valido."
      elif [[ -z $storedVarValue && ! "${validOptions[0]}" == "*" ]]; then 
        echo "Debe ingresar un valor"
      else 
        break
      fi
    done
}

#Usage: IsTextInArray toFind (array of values)
IsTextInArray() {
  local text=$1    # The first argument is the text to search for
  shift           # Shift the arguments, removing the text
  local list=("$@") # The remaining arguments are the list


  for value in "${list[@]}"; do
    if [[ "$value" == "$text" ]]; then
      return $(TRUE)
    fi
  done

  return $(FALSE)
}

ThrowError(){
  echo ""
  echo "ERROR!!! - $1"
  echo ""
  echo "Exiting"
  EXIT_ERROR
}
#############################################################################
################################## HELP #####################################
ShowHelp(){
  echo ""
  echo "Script for generate a bancon Connector - Version: $scriptVersion"
  echo ""
  echo "This script need to have configured 2 main variables that have to be set"
  echo "The first time it runs will promt to setup those variables"
  echo "Use examples:"
  echo "    bash $0 -c transfers"
  echo "    (If no version is given will generate current version)"
  echo ""
  echo "    bash $0 -c transfers -v 1.0.99"
  echo "    bash $0 -c transfers -v next" 
  echo "    (if curent version is 1.0.98 will will add one to the min in this eg will be 1.0.99)"
  echo ""
  echo "    bash $0 -c transfers -v next -i" 
  echo "    (In this example after generate JAR and POM it will be installed in your local maven)" 
  echo ""
  echo "    bash $0 -c transfers -v next -m" 
  echo "    (In this example after generate JAR and POM it will copied to a default location ($moveGeneratedConnectorPath)"
  echo "    bash $0 -c transfers -v next -M /home/myuser/Desktop" 
  echo "    (In this example after generate JAR and POM it will copied to the given path)" 
  echo ""
  echo "    bash $0"
  echo "    (Prompts will start)"
  echo ""
  echo "Questions, suggestions or report a bug to mailto:jsantacruz@bancor.com.ar<Juan Ignacio Santa Cruz>"
  echo ""
  echo "Arguments" 
  echo ""
  echo "   -h, Show help information"
  echo ""
  echo "   -s, Runs initial setup."
  echo ""
  echo "   -r, Clear all the changes in the branch after generated the apk."
  echo "       IMPORTANT: this will WIPE all the changes and sets the branch to the HEAD commit"
  echo ""
  echo "   -c, <CONNECTOR> Any connector name, the given parameter will be validated from any of the folders in /connector"
  echo ""
  echo "   -v, <VERSION> The version number to be generated, it will automatically modify the respective files .rb and .pom with the new version"
  echo "       Possible values:"
  echo "        - next: will look for current version and add one to the min version eg 1.0.10 will generate 1.0.11"
  echo "        - x.x.x: Any version like number 1.1.0"
  echo ""
  echo "   -i, Installs the generated .jar and .pom in your local maven automatically."
  echo ""
  echo "   -m, Moves the generated connector to default folder: $moveGeneratedConnectorPath."
  echo ""
  echo "   -M, <PATH> Moves the generated connector to the given folder."
  echo ""

  EXIT
}
#############################################################################
############################### SELF SETUP ##################################
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

SelfSetup(){
    echo ""
    echo "First run, running one time self setup, you will be ask to setup 2 variables."
    echo "####################################################################"
    echo ""
    echo "Before start setting things up there is an example of how the variables might look like."
    echo ""
    echo "1- Write the path to ar-bancor-omnichannel project: /opt/work/projects/ar-bancor-omnichannel"
    echo "2- Write the path of maven .m2 folder: /home/username/.m2"
    echo ""
    echo "####################################################################"
    echo ""
    AskParameter "1- Write your path to ar-bancor-omnichannel project: " newOmnichannelFolder
    echo ""
    AskParameter "2- Write your path to maven .m2 folder: " newM2Folder
    echo ""
    echo "####################################################################"
    echo ""

    echo "Script project path now is: $newOmnichannelFolder"
    echo "Script .m2 folder now is:   $newM2Folder"

    echo ""
    sed -i "s+$ommnichannelFolder+$newOmnichannelFolder+g" $0
    sed -i "s+$m2Folder+$newM2Folder+g" $0
    sed -i "s+lastPath='$lastPath'+lastPath='$currentPath'+g" $0

    echo "Self setup is DONE!!"
    echo "(If something went wrong have can be manually change later on or re-run this script by using -s parameter.)"
    echo ""

    EXIT
}

DoFirstRunCheck(){
  if [ "$lastPath" != "$currentPath" ]; then 
      return $(TRUE)
  fi

  return $(FALSE)
}

GetXmlTagValue() {
  local xml_file="$1"
  local tag_name="$2"

  if [[ ! -f "$xml_file" ]]; then
    ThrowError "Error: XML file '$xml_file' not found or not readable."
  fi

  # Read the XML file line by line
  while read line; do
    # Find the opening tag
    openingTag="<${tag_name}>"
    if [[ "$line" == *"${openingTag}"* ]]; then
      # Extract the value (assuming it's on the same line)
      value=$(echo "$line" | sed "s/$openingTag//g") # Remove tags
      value=$(echo "$value" | sed 's/<\/*.*>//g') # Remove closing tags
      echo "$value"
    fi
  done < "$xml_file"
}

#Creates a tree file path and subfolders if not exists.
CreatePath() {
  local path="$1"
  # Check if the path exists
  if [ ! -d "$path" ]; then
    # Create the path recursively
    mkdir -p "$path"
  fi
}
#############################################################################
######################## IMPLEMENTATION FUNCTIONS ###########################
BuildTargetConnectorPath(){
  echo "$connectorFolder/$connectorName"
}

BuildTargetConnectorGenerateRbFilePath(){
  echo "$(BuildTargetConnectorPath)/generate.rb"
}

BuildMavenTargetConnectorPath(){
  local version=""
  if [ ! -z "$1" ]; then
    version="$1"
  fi
  echo "$m2BanconConnectorFolder/$(BuildConnectorStoreFolder $version)"
}

BuildConnectorStoreFolder(){
  local version=""
  if [ ! -z "$1" ]; then
    version="/$1"
  fi
  echo "ar-bancor-esb-$connectorName-connector$version"
}

UpdateConnectorRbVersion(){
  currentRbVersion="name=\"version\" value=\"$(GetConnectorCurrentVersion)\""
  newRbVersion="name=\"version\" value=\"$connectorTargetVersion\""
  sed -i "s+$currentRbVersion+$newRbVersion+g" "$(BuildTargetConnectorGenerateRbFilePath)"
}

UpdateConnectorPomVersion(){
  pomConnectorCurrentVersion="$(GetConnectorCurrentVersion)"
  connectorVersionTag="corebanking.connector.$connectorName.version"
  connectorCurrentFullTag="<$connectorVersionTag>$pomConnectorCurrentVersion</$connectorVersionTag>"
  newConnectorCurrentFullTag="<$connectorVersionTag>$connectorTargetVersion</$connectorVersionTag>"
  sed -i "s+$connectorCurrentFullTag+$newConnectorCurrentFullTag+g" $omnichannelApiPom
}

GetConnectorCurrentVersion(){
  tag="corebanking.connector.$connectorName.version"
  echo $(GetXmlTagValue $omnichannelApiPom $tag)
}

GetConnectorNextVersion() {
  local version=$(GetConnectorCurrentVersion)

    # Extract the number after the last dot
  local last_version=$(echo "$version" | cut -d '.' -f 3)

  # Add 1 to the extracted number
  local new_version=$((last_version + 1))

  # Replace the old number with the new one using sed
  local updated_version=$(echo "$version" | sed "s/\.$last_version$/.${new_version}/")

  # Print the updated version
  echo "$updated_version"
}

GetConnectorNames() {
  local path=$connectorFolder
  local folders=()

  if [[ ! -d "$connectorFolder" ]]; then
    #"Error: $connectorFolder no es un directorio válido."
    return "${folders[@]}"
  fi

  local ls_output=$(ls -d "$path"/*)

  for folder in $ls_output; do
    folder_name=$(basename "$folder")
    if [[ "$folder_name" != "." && "$folder_name" != "unify-wsdl.rb" ]]; then
      folders+=("$folder_name")
    fi
  done

  echo "${folders[@]}"
}

IsValidConnector(){
  if IsTextInArray $1 $(GetConnectorNames); then
    return $(TRUE);
  fi
  
  return $(FALSE);
}

GetGeneratedConnectorJARFilePath(){
  local version="$1"
  local connectorPath="$(BuildTargetConnectorPath)"
  local jarFileName="ar-bancor-esb-$connectorName-connector-$version.jar"
  echo "$connectorPath/$jarFileName"
}

GetGeneratedConnectorPOMFilePath(){
  local version="$1"
  local connectorPath="$(BuildTargetConnectorPath)"
  local pomFileName="ar-bancor-esb-$connectorName-connector-$version.pom"
  echo "$connectorPath/$pomFileName"
}
#############################################################################
########################## SCRIPT INITIALIZATION ############################
if $runShowHelp; then 
  ShowHelp
fi

if DoFirstRunCheck || $runFirstSetup; then 
    echo "Starting Script Initial Setup..."
    SelfSetup
fi

#############################################################################

#Ask for connector name if param was not given or validate the given connector name
if $promptConnectorName; then
  AskParameter "Que connector se va generar?: " connectorName "$(GetConnectorNames)"
else 
  if ! IsValidConnector $connectorName; then
    ThrowError "El connector ($connectorName) no existe."
  fi
fi

connectorTarget=$(BuildTargetConnectorPath)
connectorCurrentVersion=$(GetConnectorCurrentVersion)

if [ ! -d $connectorTarget ]; then
  ThrowError "El path al connector no existe >> $connectorTarget"
fi

if [ $connectorTargetVersion == "next" ]; then
  connectorTargetVersion="$(GetConnectorNextVersion)"
fi

#Start
cd $connectorTarget

#Step 0.1
if [ ! -z $connectorTargetVersion ]; then
  UpdateConnectorRbVersion  
fi

#Step 1
ruby generate.rb
DrawSeparatorLine

#Step 2
ant -f generate.xml all
DrawSeparatorLine

#Step 3
cd ..
ruby unify-wsdl.rb 
DrawSeparatorLine

#Step 4
if [ ! -z $connectorTargetVersion ]; then
  UpdateConnectorPomVersion
fi

connectorFinalVersion=$connectorCurrentVersion
if [ ! -z $connectorTargetVersion ]; then
  connectorFinalVersion=$connectorTargetVersion
fi

generatedConnectorJARFilePath="$(GetGeneratedConnectorJARFilePath $connectorFinalVersion)"
generatedConnectorPOMFilePath="$(GetGeneratedConnectorPOMFilePath $connectorFinalVersion)"

#Optional Step 6 - Install to local maven folder
if $addConnectorTolocalMaven; then
  echo "Connector maven"
  localMavenConnectorPath=$(BuildMavenTargetConnectorPath $connectorFinalVersion)
  CreatePath $localMavenConnectorPath
  cp $generatedConnectorJARFilePath $localMavenConnectorPath
  cp $generatedConnectorPOMFilePath $localMavenConnectorPath
  echo "Connector is now installed in $localMavenConnectorPath"
fi

#Optional Step 7 - Move jar and pom to specific folder
if $moveGeneratedConnector; then
  moveGeneratedConnectorFinalPath="$moveGeneratedConnectorPath/$(BuildConnectorStoreFolder $connectorFinalVersion)"
  CreatePath $moveGeneratedConnectorFinalPath
  cp $generatedConnectorJARFilePath $moveGeneratedConnectorFinalPath
  cp $generatedConnectorPOMFilePath $moveGeneratedConnectorFinalPath
  echo "Connector JAR and POM is now in folder $moveGeneratedConnectorFinalPath"
fi

#End
notify-send "Conector generado." "Se completó la generación del connector $connectorName versión $connectorFinalVersion."

#Clean 
if $cleanBranchChanges; then
  CleanChanges
fi