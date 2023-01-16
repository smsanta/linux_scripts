#!/bin/sh

SCRIPT_PATH=$(pwd)

[ "$(whoami)" != "root" ] && exec sudo sh $SCRIPT_PATH/$0 $1

TOMCAT_PORT="3000"

echo "Searching Pid for port: "$TOMCAT_PORT

netstat -nlp | grep $TOMCAT_PORT

portPidProcess=$(sockstat -4 -l | grep :$TOMCAT_PORT | awk '{print $3}' | head -1)

if [ -z "$portPidProcess" ]; then
    echo "Nothing to kill in port $TOMCAT_PORT."
    exit
fi

echo "Killing process Pid: "$portPidProcess

exec kill $portPidProcess -9

