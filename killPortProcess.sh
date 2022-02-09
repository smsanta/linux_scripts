#!/bin/sh

SCRIPT_PATH=$(pwd)

[ "$(whoami)" != "root" ] && exec sudo sh $SCRIPT_PATH/$0 $1

if [ $# -eq 0 ]
  then
    echo "Must provide a port to kill."
    exit
fi

echo "Searching Pid for port: "$1

netstat -nlp | grep $1

portPidProcess=$(sockstat -4 -l | grep :$1 | awk '{print $3}' | head -1)

if [ -z "$portPidProcess" ]; then
    echo "Nothing to kill in port $1."
    exit
fi

echo "Killing process Pid: "$portPidProcess

exec kill $portPidProcess -9


