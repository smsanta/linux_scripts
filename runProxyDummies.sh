#!/bin/bash
SCRIPT_PATH=$(pwd)

[ "$(whoami)" != "root" ] && exec sudo sh $SCRIPT_PATH/$0

dockerCheck=$(docker container ls -a | grep oracle-db-12c-r2 | grep Up)

if [ -z "$dockerCheck" ]; then
    echo "Docker Is NOT Running."
    echo "Launching Docker Container - oracle-db-12c-r2"
    sudo docker start -a oracle-12c-r2 > /dev/null &
    sleep 10
    echo "Proxy Dummies will be launched in 10 seconds."
fi

echo "Launching Proxy Dummies."
sleep 1
##export JAVA_HOME=${SDKMAN_CANDIDATES_DIR}/java/${CURRENT}/bin
echo "Home> $JAVA_HOME"
sh /opt/work/apache-tomcat-8.5.71-pd/bin/catalina.sh run
