#!/bin/sh

SCRIPT_PATH=$(pwd)

[ "$(whoami)" != "root" ] && exec sudo sh $SCRIPT_PATH/$0

dockerCheck=$(docker container ls -a | grep oracle-db-12c-r2 | grep Up)

if [ -z "$dockerCheck" ]; then
    echo "Docker - oracle-db-12c-r2 - Is NOT Running."
    echo "Launching Docker Container - oracle-db-12c-r2"
    sudo docker start -a oracle-12c-r2 > /dev/null &
else
    echo "Docker - oracle-db-12c-r2 - Is Running."
fi

